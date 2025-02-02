# Makefile for KGEN-generated kernel

include ./Macros

ALL_OBJS := kernel_driver.o radiation.o kgen_utils.o radsw.o rrsw_kg28.o rrtmg_state.o rrsw_kg25.o rrsw_kg19.o rrtmg_sw_reftra.o rrsw_cld.o parrrsw.o physics_types.o rrsw_tbl.o rrtmg_sw_rad.o rrsw_kg23.o cmparray_mod.o rrsw_con.o rrsw_wvn.o rrsw_kg27.o rrsw_ref.o rrsw_kg24.o rrsw_kg16.o rrsw_vsn.o scamMod.o constituents.o shr_const_mod.o shr_kind_mod.o rrtmg_sw_cldprmc.o rrsw_kg17.o radconstants.o rrsw_kg20.o rrsw_kg29.o rrsw_kg22.o mcica_subcol_gen_sw.o rrtmg_sw_taumol.o camsrfexch.o ppgrid.o rrtmg_sw_vrtqdr.o rrsw_kg26.o rrsw_kg18.o rrsw_kg21.o rrtmg_sw_spcvmc.o physconst.o mcica_random_numbers.o rrtmg_sw_setcoef.o

run: build

build: ${ALL_OBJS}
	${FC} ${LD_FLAGS}   -o kernel.exe $^

kernel_driver.o: kernel_driver.F90 radiation.o kgen_utils.o radsw.o rrsw_kg28.o rrtmg_state.o rrsw_kg25.o rrsw_kg19.o rrtmg_sw_reftra.o rrsw_cld.o parrrsw.o physics_types.o rrsw_tbl.o rrtmg_sw_rad.o rrsw_kg23.o cmparray_mod.o rrsw_con.o rrsw_wvn.o rrsw_kg27.o rrsw_ref.o rrsw_kg24.o rrsw_kg16.o rrsw_vsn.o scamMod.o constituents.o shr_const_mod.o shr_kind_mod.o rrtmg_sw_cldprmc.o rrsw_kg17.o radconstants.o rrsw_kg20.o rrsw_kg29.o rrsw_kg22.o mcica_subcol_gen_sw.o rrtmg_sw_taumol.o camsrfexch.o ppgrid.o rrtmg_sw_vrtqdr.o rrsw_kg26.o rrsw_kg18.o rrsw_kg21.o rrtmg_sw_spcvmc.o physconst.o mcica_random_numbers.o rrtmg_sw_setcoef.o
	${FC} ${FC_FLAGS} -c -o $@ $<

radiation.o: radiation.F90 kgen_utils.o radsw.o ppgrid.o shr_kind_mod.o parrrsw.o rrtmg_state.o physics_types.o camsrfexch.o radconstants.o
	${FC} ${FC_FLAGS} -c -o $@ $<

radsw.o: radsw.F90 kgen_utils.o shr_kind_mod.o ppgrid.o parrrsw.o rrtmg_state.o scamMod.o cmparray_mod.o mcica_subcol_gen_sw.o rrtmg_sw_rad.o physconst.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg28.o: rrsw_kg28.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrtmg_state.o: rrtmg_state.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg25.o: rrsw_kg25.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg19.o: rrsw_kg19.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrtmg_sw_reftra.o: rrtmg_sw_reftra.F90 kgen_utils.o shr_kind_mod.o rrsw_vsn.o rrsw_tbl.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_cld.o: rrsw_cld.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

parrrsw.o: parrrsw.F90 kgen_utils.o
	${FC} ${FC_FLAGS} -c -o $@ $<

physics_types.o: physics_types.F90 kgen_utils.o ppgrid.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_tbl.o: rrsw_tbl.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrtmg_sw_rad.o: rrtmg_sw_rad.F90 kgen_utils.o shr_kind_mod.o parrrsw.o rrsw_con.o rrtmg_sw_cldprmc.o rrtmg_sw_setcoef.o rrtmg_sw_spcvmc.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg23.o: rrsw_kg23.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

cmparray_mod.o: cmparray_mod.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_con.o: rrsw_con.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_wvn.o: rrsw_wvn.F90 kgen_utils.o parrrsw.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg27.o: rrsw_kg27.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_ref.o: rrsw_ref.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg24.o: rrsw_kg24.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg16.o: rrsw_kg16.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_vsn.o: rrsw_vsn.F90 kgen_utils.o
	${FC} ${FC_FLAGS} -c -o $@ $<

scamMod.o: scamMod.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

constituents.o: constituents.F90 kgen_utils.o
	${FC} ${FC_FLAGS} -c -o $@ $<

shr_const_mod.o: shr_const_mod.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

shr_kind_mod.o: shr_kind_mod.F90 kgen_utils.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrtmg_sw_cldprmc.o: rrtmg_sw_cldprmc.F90 kgen_utils.o shr_kind_mod.o parrrsw.o rrsw_vsn.o rrsw_wvn.o rrsw_cld.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg17.o: rrsw_kg17.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

radconstants.o: radconstants.F90 kgen_utils.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg20.o: rrsw_kg20.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg29.o: rrsw_kg29.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg22.o: rrsw_kg22.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

mcica_subcol_gen_sw.o: mcica_subcol_gen_sw.F90 kgen_utils.o shr_kind_mod.o parrrsw.o mcica_random_numbers.o rrsw_wvn.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrtmg_sw_taumol.o: rrtmg_sw_taumol.F90 kgen_utils.o shr_kind_mod.o rrsw_vsn.o rrsw_kg16.o rrsw_con.o rrsw_wvn.o parrrsw.o rrsw_kg17.o rrsw_kg18.o rrsw_kg19.o rrsw_kg20.o rrsw_kg21.o rrsw_kg22.o rrsw_kg23.o rrsw_kg24.o rrsw_kg25.o rrsw_kg26.o rrsw_kg27.o rrsw_kg28.o rrsw_kg29.o
	${FC} ${FC_FLAGS} -c -o $@ $<

camsrfexch.o: camsrfexch.F90 kgen_utils.o shr_kind_mod.o ppgrid.o constituents.o
	${FC} ${FC_FLAGS} -c -o $@ $<

ppgrid.o: ppgrid.F90 kgen_utils.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrtmg_sw_vrtqdr.o: rrtmg_sw_vrtqdr.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg26.o: rrsw_kg26.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg18.o: rrsw_kg18.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrsw_kg21.o: rrsw_kg21.F90 kgen_utils.o shr_kind_mod.o parrrsw.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrtmg_sw_spcvmc.o: rrtmg_sw_spcvmc.F90 kgen_utils.o shr_kind_mod.o parrrsw.o rrtmg_sw_taumol.o rrsw_wvn.o rrsw_tbl.o rrtmg_sw_reftra.o rrtmg_sw_vrtqdr.o
	${FC} ${FC_FLAGS} -c -o $@ $<

physconst.o: physconst.F90 kgen_utils.o shr_kind_mod.o shr_const_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

mcica_random_numbers.o: mcica_random_numbers.F90 kgen_utils.o shr_kind_mod.o
	${FC} ${FC_FLAGS} -c -o $@ $<

rrtmg_sw_setcoef.o: rrtmg_sw_setcoef.F90 kgen_utils.o shr_kind_mod.o rrsw_ref.o
	${FC} ${FC_FLAGS} -c -o $@ $<

kgen_utils.o: kgen_utils.F90
	${FC} ${FC_FLAGS} -c -o $@ $<

clean:
	rm -f kernel.exe *.L *.mod *.o
