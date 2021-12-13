int main(void) {
  extern char _test_start;
  extern char _binary_image_bmp_start;
  extern char _binary_image_bmp_end;
  extern unsigned int _binary_image_bmp_size;

  int i;
  for(i=0; i<54; i++)
    (&_test_start)[i]=(&_binary_image_bmp_start)[i];

  int j;
  int a=0,b=0,c=0;
  for(j=54; j < &_binary_image_bmp_size; j=j+3){
    int result=0, tmp=0;
    c=(&_binary_image_bmp_start)[j];
    b=(&_binary_image_bmp_start)[j+1];
    a=(&_binary_image_bmp_start)[j+2];
    tmp=a<<18;
    result+=tmp;
    tmp=a<<15;
    result+=tmp;
    tmp=a<<14;
    result+=tmp;
    tmp=a<<11;
    result+=tmp;
    tmp=a<<10;
    result+=tmp;
    tmp=a<<7;
    result+=tmp;
    tmp=a<<6;
    result+=tmp;
    tmp=a<<3;
    result+=tmp;
    tmp=a<<2;
    result+=tmp;
    result+=a;
    
    tmp=b<<19;
    result+=tmp;
    tmp=b<<16;
    result+=tmp;
    tmp=b<<14;
    result+=tmp;
    tmp=b<<13;
    result+=tmp;
    tmp=b<<12;
    result+=tmp;
    tmp=b<<7;
    result+=tmp;
    tmp=b<<5;
    result+=tmp;
    tmp=b<<2;
    result+=tmp;

    tmp=c<<16;
    result+=tmp;
    tmp=c<<15;
    result+=tmp;
    tmp=c<<14;
    result+=tmp;
    tmp=c<<9;
    result+=tmp;
    tmp=c<<7;
    result+=tmp;
    tmp=c<<4;
    result+=tmp;
    
    result = result >> 20;

    (&_test_start)[j]=result;
    (&_test_start)[j+1]=result;
    (&_test_start)[j+2]=result;
  }
  return 0;
  
}
