

void boot() {
  extern unsigned int _dram_i_start;
  extern unsigned int _dram_i_end;
  extern unsigned int _imem_start;

  extern unsigned int __sdata_start;
  extern unsigned int __sdata_end;
  extern unsigned int __sdata_paddr_start;

  extern unsigned int __data_start;
  extern unsigned int __data_end;
  extern unsigned int __data_paddr_start;

	int i;
	int num ;

	num = (&_dram_i_end) - (&_dram_i_start);
	for(i = 0; i <= num; i++)
		(&_imem_start)[i] = (&_dram_i_start)[i];

	num = (&__sdata_end) - (&__sdata_start);
	for(i = 0; i <= num; i++)
		(&__sdata_paddr_start)[i] = (&__sdata_start)[i];

	num = (&__data_end) - (&__data_start);
	for(i = 0; i <= num; i++)
		(&__data_paddr_start)[i] = (&__data_start)[i];
}
