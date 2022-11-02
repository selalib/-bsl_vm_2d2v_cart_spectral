SIM_NAME = bsl_dk_3d1v_polar
SLL_DIR ?= /opt/selalib
FC = h5pfc
FFLAGS = -w -ffree-line-length-none -fall-intrinsics -O3 -fPIC -march=native -I${SLL_DIR}/include/selalib
#FFLAGS = -w -ffree-line-length-none -fall-intrinsics -g -O0 -fPIC -march=native -I${SLL_DIR}/include/selalib
FFTWLIB = -L/usr/local/lib -lfftw3
FLIBS = -L${SLL_DIR}/lib -lselalib -ldfftpack ${FFTWLIB}

OBJS =	init_functions.o \
	sll_vlasov4d_base.o sll_vlasov4d_maxwell.o sll_vlasov4d_poisson.o \
	sll_vlasov4d_spectral.o sll_vlasov4d_spectral_charge.o 

default: vp4d_remapper.exe vm4d_spectral.exe vm4d_spectral_charge.exe \
         vp4d_sequential.exe

vp4d_remapper.exe: ${OBJS} vp4d_remapper.o
	${FC} ${FFLAGS} -o $@ $^ -I${SLL_DIR}/include/selalib ${FLIBS}

vm4d_spectral.exe: ${OBJS} vm4d_spectral.o
	${FC} ${FFLAGS} -o $@ $^ -I${SLL_DIR}/include/selalib ${FLIBS}

vm4d_spectral_charge.exe: ${OBJS} vm4d_spectral_charge.o
	${FC} ${FFLAGS} -o $@ $^ -I${SLL_DIR}/include/selalib ${FLIBS}

vp4d_sequential.exe: ${OBJS} vp4d_sequential.o 
	${FC} ${FFLAGS} -o $@ $^ -I${SLL_DIR}/include/selalib ${FLIBS}

clean: 
	rm -f *.o *.exe *.mod

selalib:
	git clone https://github.com/selalib/selalib

sllbuild: selalib
	mkdir -p $@
	cd $@; cmake ../selalib -DHDF5_PARALLEL_ENABLED=ON \
                  -DCMAKE_INSTALL_PREFIX=${SLL_DIR} \
                  -DCMAKE_BUILD_TYPE=Release \
 	          -DBUILD_TESTING=OFF -DBUILD_SIMULATIONS=OFF; make install

.SUFFIXES: $(SUFFIXES) .F90

.F90.o:
	$(FC) $(FFLAGS) -c $<

.mod.o:
	$(FC) $(FFLAGS) -c $*.F90

init_functions.o: init_functions.F90
sll_vlasov4d_base.o: sll_vlasov4d_base.F90 
sll_vlasov4d_maxwell.o: sll_vlasov4d_maxwell.F90 
sll_vlasov4d_poisson.o: sll_vlasov4d_poisson.F90
sll_vlasov4d_spectral.o: sll_vlasov4d_spectral.F90 
sll_vlasov4d_spectral_charge.o: sll_vlasov4d_spectral_charge.F90
