extern long long mul1;
extern long long mul2;
extern int _test_start;

typedef unsigned long long int UINT64;
typedef signed long long int INT64;

int main(void){
  INT64 mul1_64, mul2_64;
  mul1_64 = (mul1 << 32) >> 32;
  mul2_64 = (mul2 << 32) >> 32;
  INT64 res = mul1_64 * mul2_64;
  
  (&_test_start)[0] = res;
  (&_test_start)[1] = res >> 32;
  return 0; 
}
