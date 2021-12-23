void boot() {
  extern unsigned int _dram_i_start; // instruction start address in DRAM
  extern unsigned int _dram_i_end; // instruction end address in DRAM
  extern unsigned int _imem_start; // instruction start address in IM

  extern unsigned int __sdata_start; // Main_data start address in DM
  extern unsigned int __sdata_end; // Main_data end address in DM
  extern unsigned int __sdata_paddr_start; // Main_data start address in DRAM

  extern unsigned int __data_start; // Main_data start address in DM
  extern unsigned int __data_end; // Main_data end address in DM
  extern unsigned int __data_paddr_start; // Main_data start address in DRAM

	int i;
	int num;

	// Move instruction from DRAM to IM
	num = (&_dram_i_end) - (&_dram_i_start);
	for(i = 0; i <= num; i++)
		(&_imem_start)[i] = (&_dram_i_start)[i];

	// Move data from DRAM to DM (part 1)
	num = (&__data_end) - (&__data_start);
	for(i = 0; i <= num; i++)
		(&__data_start)[i] = (&__data_paddr_start)[i];

	// Move data from DRAM to DM (part 2)
	num = (&__sdata_end) - (&__sdata_start);
	for(i = 0; i <= num; i++)
		(&__sdata_start)[i] = (&__sdata_paddr_start)[i];
}
