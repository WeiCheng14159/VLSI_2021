wvResizeWindow -win $_nWave1 0 23 2560 1017
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/home/wei/VLSI_2021/hw2/P76091226/build/top.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/top_tb"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/axi/AWx"
wvSetPosition -win $_nWave1 {("G1" 30)}
wvSetPosition -win $_nWave1 {("G1" 30)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/top_tb/TOP/axi/AWx/ADDR_M1\[31:0\]} \
{/top_tb/TOP/axi/AWx/ADDR_M\[31:0\]} \
{/top_tb/TOP/axi/AWx/ADDR_S0\[31:0\]} \
{/top_tb/TOP/axi/AWx/ADDR_S1\[31:0\]} \
{/top_tb/TOP/axi/AWx/ADDR_S2\[31:0\]} \
{/top_tb/TOP/axi/AWx/BURST_M1\[1:0\]} \
{/top_tb/TOP/axi/AWx/BURST_M\[1:0\]} \
{/top_tb/TOP/axi/AWx/BURST_S0\[1:0\]} \
{/top_tb/TOP/axi/AWx/BURST_S1\[1:0\]} \
{/top_tb/TOP/axi/AWx/BURST_S2\[1:0\]} \
{/top_tb/TOP/axi/AWx/ID_M1\[3:0\]} \
{/top_tb/TOP/axi/AWx/ID_M\[7:0\]} \
{/top_tb/TOP/axi/AWx/ID_S0\[7:0\]} \
{/top_tb/TOP/axi/AWx/ID_S1\[7:0\]} \
{/top_tb/TOP/axi/AWx/ID_S2\[7:0\]} \
{/top_tb/TOP/axi/AWx/LEN_M1\[3:0\]} \
{/top_tb/TOP/axi/AWx/LEN_M\[3:0\]} \
{/top_tb/TOP/axi/AWx/LEN_S0\[3:0\]} \
{/top_tb/TOP/axi/AWx/LEN_S1\[3:0\]} \
{/top_tb/TOP/axi/AWx/LEN_S2\[3:0\]} \
{/top_tb/TOP/axi/AWx/READY_M1} \
{/top_tb/TOP/axi/AWx/READY_S0} \
{/top_tb/TOP/axi/AWx/READY_S1} \
{/top_tb/TOP/axi/AWx/READY_S2} \
{/top_tb/TOP/axi/AWx/READY_from_slave} \
{/top_tb/TOP/axi/AWx/SIZE_M1\[2:0\]} \
{/top_tb/TOP/axi/AWx/SIZE_M\[2:0\]} \
{/top_tb/TOP/axi/AWx/SIZE_S0\[2:0\]} \
{/top_tb/TOP/axi/AWx/SIZE_S1\[2:0\]} \
{/top_tb/TOP/axi/AWx/SIZE_S2\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 )} 
wvSetPosition -win $_nWave1 {("G1" 30)}
wvGetSignalClose -win $_nWave1
wvRestoreSignal -win $_nWave1 "/home/wei/VLSI_2021/hw2/P76091226/integ_1.rc" \
           -overWriteAutoAlias on
wvResizeWindow -win $_nWave1 2560 23 1920 1137
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvExit
