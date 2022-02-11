#include "printf.h"
#include "trap.h"
#include "mul.h"
#include "div.h"

#define FRAC_BIT 10

#define RD_ADDR 135106448
#define RD_SIZE_D0 1
#define RD_SIZE_D1 1
#define RD_SIZE_D2 28
#define RD_SIZE_D3 28

#define WEIGHT_ADDR 134217728
#define WEIGHT_SIZE_D0 20
#define WEIGHT_SIZE_D1 1
#define WEIGHT_SIZE_D2 5
#define WEIGHT_SIZE_D3 5

#define WR_ADDR 135108240
#define WR_SIZE_D0 1
#define WR_SIZE_D1 20
#define WR_SIZE_D2 12
#define WR_SIZE_D3 12

#define KERN_ATTR_CONV_PAD 0
#define KERN_ATTR_CONV_STRIDE 1
#define KERN_ATTR_POOL_PAD 0
#define KERN_ATTR_POOL_KERN_SIZE 2
#define KERN_ATTR_POOL_STRIDE 2

struct size_vec4
{
	unsigned d0;
	unsigned d1;
	unsigned d2;
	unsigned d3;
};

struct mem_addr
{
	unsigned rd_addr;
	unsigned weight_addr;
	unsigned wr_addr;
};

int mul(short a, short b)
{
	int ans = mul_ll(a, b);
	return ans;
}

struct mem_addr addr = {RD_ADDR, WEIGHT_ADDR, WR_ADDR};
struct size_vec4 rd_size = {RD_SIZE_D0, RD_SIZE_D1, RD_SIZE_D2, RD_SIZE_D3};
struct size_vec4 wr_size = {WR_SIZE_D0, WR_SIZE_D1, WR_SIZE_D2, WR_SIZE_D3};
struct size_vec4 weight_size = {WEIGHT_SIZE_D0, WEIGHT_SIZE_D1, WEIGHT_SIZE_D2, WEIGHT_SIZE_D3};

struct size_vec4 conv_size;

extern char _binary_lib_sw_conv_result_bin_start[];
extern char _binary_lib_sw_conv_result_bin_size[];

void convolution()
{
	short *in = (short *)addr.rd_addr;
	short *weight = (short *)addr.weight_addr;
	short *out = (short *)addr.wr_addr;

	unsigned output_offset = 0;
	unsigned input_offset = 0;

	unsigned input_fm_w = rd_size.d3;
	unsigned input_fm_h = rd_size.d2;

	unsigned pad = KERN_ATTR_CONV_PAD;
	unsigned pad_len = pad << 1;

	unsigned conv_out_w = rd_size.d3 - weight_size.d3 + pad_len;
	unsigned conv_out_h = rd_size.d2 - weight_size.d2 + pad_len;

	unsigned stride = KERN_ATTR_CONV_STRIDE;

	conv_out_w = div(conv_out_w, stride);
	conv_out_h = div(conv_out_h, stride);

	conv_out_w++;
	conv_out_h++;

	conv_size.d0 = wr_size.d0;
	conv_size.d1 = wr_size.d1;
	conv_size.d2 = conv_out_h;
	conv_size.d3 = conv_out_w;

	unsigned weight_offset = 0;

	unsigned weight_len = (WEIGHT_SIZE_D2 * WEIGHT_SIZE_D3);

	short in_data, wgt_data, bias;
	int product;

	int out_tmp = 0;

	for (int oc = 0; oc < wr_size.d1; oc++)
	{

		for (int oh = 0; oh < conv_out_h; oh++)
		{
			for (int ow = 0; ow < conv_out_w; ow++)
			{

				short *weight_tmp = weight;
				output_offset = ow + mul(conv_out_w, (oh + mul(conv_out_h, oc)));

				for (int ic = 0; ic < rd_size.d1; ic++)
				{
					bias = *weight_tmp;
					weight_tmp++;

					if (ic == 0)
					{
						product = (int)bias;
						out_tmp = (product << FRAC_BIT);
					}

					for (int kh = 0; kh < weight_size.d2; kh++)
					{
						for (int kw = 0; kw < weight_size.d3; kw++)
						{
							int iw = kw + mul(ow, stride);
							int ih = kh + mul(oh, stride);

							if ((iw < pad) || (iw >= (input_fm_w + pad)))
								continue;

							if ((ih < pad) || (ih >= (input_fm_h + pad)))
								continue;

							iw -= pad;
							ih -= pad;

							input_offset = iw + mul(input_fm_w, (ih + mul(input_fm_h, ic)));
							weight_offset = kw + mul(weight_size.d3, kh);

							in_data = *(in + input_offset);
							wgt_data = *(weight_tmp + weight_offset);
							product = mul(in_data, wgt_data);
							out_tmp += product;
						}
					}
					weight_tmp += weight_len;
				}
				*(out + output_offset) = out_tmp >> FRAC_BIT;
				//		printf("%x ",out_tmp >> FRAC_BIT);
			}
		}
		weight += mul(rd_size.d1, (weight_len + 1));
	}
}

void pooling()
{
	short *out = (short *)addr.wr_addr;

	unsigned output_offset = 0;
	unsigned input_offset = 0;

	unsigned input_fm_w = conv_size.d3;
	unsigned input_fm_h = conv_size.d2;

	unsigned pad = KERN_ATTR_POOL_PAD;
	unsigned pad_len = pad << 1;

	unsigned pad_w_test = conv_size.d3 - KERN_ATTR_POOL_KERN_SIZE;
	unsigned pad_h_test = conv_size.d2 - KERN_ATTR_POOL_KERN_SIZE;

	unsigned pool_out_w = pad_w_test + pad_len;
	unsigned pool_out_h = pad_h_test + pad_len;

	unsigned stride = KERN_ATTR_POOL_STRIDE;

	unsigned pad_w_test_remain = pad_w_test - mul(div(pad_w_test, stride), stride);
	unsigned pad_h_test_remain = pad_h_test - mul(div(pad_h_test, stride), stride);

	pool_out_w = div(pool_out_w, stride);
	pool_out_h = div(pool_out_h, stride);
	pool_out_w++;
	pool_out_h++;

	if ((!pad) && (pad_w_test_remain || pad_h_test_remain))
	{
		pool_out_w++;
		pool_out_h++;
	}

	struct size_vec4 pool_size = {conv_size.d0, conv_size.d1, pool_out_h, pool_out_w};

	short in_data;
	short max_data = 0;

	for (int oc = 0; oc < pool_size.d1; oc++)
	{

		for (int oh = 0; oh < pool_out_h; oh++)
		{
			for (int ow = 0; ow < pool_out_w; ow++)
			{

				output_offset = ow + mul(pool_out_w, (oh + mul(pool_out_h, oc)));

				unsigned k_num = 0;

				unsigned first_k = 0;

				for (int kh = 0; kh < KERN_ATTR_POOL_KERN_SIZE; kh++)
				{
					for (int kw = 0; kw < KERN_ATTR_POOL_KERN_SIZE; kw++)
					{

						int iw = kw + mul(ow, stride);
						int ih = kh + mul(oh, stride);

						if ((iw < pad) || (iw >= (input_fm_w + pad)) || (ih < pad) || (ih >= (input_fm_h + pad)))
						{
							if (pad)
								k_num++;

							continue;
						}

						iw -= pad;
						ih -= pad;

						k_num++;

						input_offset = iw + mul(input_fm_w, (ih + mul(input_fm_h, oc)));

						in_data = *(out + input_offset);

						if (!first_k)
						{
							max_data = in_data;
							first_k = 1;
							continue;
						}

						if (in_data > max_data)
							max_data = in_data;
					}
				}
				// printf("%x ",max_data);
				*(out + output_offset) = max_data;
			}
		}
	}
}

int comparing()
{
	char *out = (char *)addr.wr_addr;
	char *result = (char *)_binary_lib_sw_conv_result_bin_start;

	int count = (int)_binary_lib_sw_conv_result_bin_size;

	for (int i = 0; i < count; i++)
	{
		if (*(out + i) != *(result + i))
		{
			printf("Failed! at address %x and %x with data %x and %x\n", out + i, result + i, *(out + i), *(result + i));
			return 1;
		}
	}

	printf("Passed!\n");
	return 0;
}

int main()
{
	printf("starting convolution\n");
	convolution();
	printf("starting pooling\n");
	pooling();
	int result = comparing();
	printf("benchmark finished\n");
	if (result == 0) {
		hit_good_trap();
	} else {
		nemu_assert(0);
	}
	return 0;
}
