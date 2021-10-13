int ripper(int,int,int*);
int main(void){
    extern int mul1;
    extern int mul2;
    extern int _test_start;
    int high=0,low=0,i,j;
    int multiplier = mul1,multiplicand=mul2,flag1=1,flag2=1;
    if(multiplier < 0) {multiplier = ~multiplier+1;flag1=0;}
    if(multiplicand <0 ) {multiplicand = ~multiplicand +1;flag2=0;}
    for(i=0;i<32;i++){
        if(multiplicand & 1){
            int carry = 0;
            int tmp = multiplier << i ;
            carry = ripper(low,tmp,&low);
            int y = i==0 ? 0: multiplier >> (32-i);
            high = high + y + carry;
        }
        multiplicand = multiplicand >> 1;
    }
    if(flag1^flag2){
        high = ~high;
        low = ~low;
        int carry = ripper(low,1,&low);
        high = high + carry;
    }
    
    (&_test_start)[0] = low;
    (&_test_start)[1] = high;
    return 0; 
}


int ripper(int x1,int x2,int *sum){
    int carry=0,i,total=0;
    for(i=0;i<32;i++){
        int bit1 = (x1 >> i ) & 1;
        int bit2 = (x2 >> i) & 1;
        int sum_bit = bit1 ^ bit2 ^ carry;
        carry = (bit1 & bit2) | (bit1 & carry) | (bit2 & carry);
        total  = total + (sum_bit << i);
    }
    *sum = total;
    return carry;
}
