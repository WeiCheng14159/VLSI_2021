void boot() {
  extern unsigned int _dram_i_start; //instruction start address in DRAM (0x20000000)
  extern unsigned int _dram_i_end; // instruction end address in DRAM (0x20000a1c)
  extern unsigned int _imem_start; // instruction start address in IM (0x00010000)

  extern unsigned int __sdata_start; // Main_data start address in DM (0x00020000)
  extern unsigned int __sdata_end; // Main_data end address in DM (0x00020000)
  extern unsigned int __sdata_paddr_start; // Main_data start address in DRAM (0x20101000)

  extern unsigned int __data_start; // Main_data start address in DM (0x00020000)
  extern unsigned int __data_end; // Main_data end address in DM (0x00020000)
  extern unsigned int __data_paddr_start; // Main_data start address in DRAM (0x20101000)

	int i;
	int num;

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
