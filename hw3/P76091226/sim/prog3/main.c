int mul(int a, int b)
{
    int sign = 1;
    if (b < 0)
    {
        sign = -sign;
        b = -b;
    }
    if (a < 0)
    {
        sign = -sign;
        a = -a;
    }
    int ret = 0;
    while (b)
    {
        if (b & 1)
        {
            ret = ret + a;
        }
        a <<= 1;
        b >>= 1;
    }
    if (sign < 0)
        return -ret;
    return ret;
}

int main(void){
  extern int array_size_i;
  extern int array_size_j;
  extern int array_size_k;
  extern short array_addr;
  extern int _test_start;

  int i=0, j=0, k=0;
  int matrix_A_addr;
  int matrix_B_addr;
  int start_matrix_B;
  start_matrix_B = mul(array_size_i, array_size_k);

  int tmp_result = 0;
  int result_addr = 0;

  for(i=0; i<array_size_i;i++)
    for(j=0; j<array_size_j; j++) {
      for(k=0; k<array_size_k; k++) {
        matrix_A_addr = mul(i, array_size_k) + k;
        matrix_B_addr = start_matrix_B + mul(k, array_size_j) + j;
        tmp_result += mul((&array_addr)[matrix_A_addr], (&array_addr)[matrix_B_addr]);
      }
      (&_test_start)[result_addr++] = tmp_result;
      tmp_result = 0;
    }

  return 0;
}

