SIM_NAME = bsl_dk_3d1v_polar
SLL_DIR ?= /opt/selalib
FC = h5pfc
FFLAGS = -w -ffree-line-length-none -fall-intrinsics -O3 -fPIC -march=native -I${SLL_DIR}/include/selalib
FFTWLIB = -lfftw3 # Add -L/usr/local/lib on macos
FLIBS = -L${SLL_DIR}/lib -lselalib -ldfftpack ${FFTWLIB}

OFILES = sll_vlasov4d_spectral.o sll_vlasov4d_spectral_charge.o sll_vlasov4d_maxwell.o sll_vlasov4d_poisson.o sll_vlasov4d_base.o init_functions.o

vp4d_remapper: ${OFILES} vp4d_remapper.o
	${FC} ${FFLAGS} -o ${SIM_NAME} $^ -I${SLL_DIR}/include/selalib ${FLIBS}

vm4d_spectral: ${OFILES} vm4d_spectral.o
	${FC} ${FFLAGS} -o ${SIM_NAME} $^ -I${SLL_DIR}/include/selalib ${FLIBS}

vm4d_spectral_charge: ${OFILES} vm4d_spectral_charge.o
	${FC} ${FFLAGS} -o ${SIM_NAME} $^ -I${SLL_DIR}/include/selalib ${FLIBS}

vm2d_spectral_charge: ${OFILES} vm2d_spectral_charge.o 
	${FC} ${FFLAGS} -o ${SIM_NAME} $^ -I${SLL_DIR}/include/selalib ${FLIBS}

vp4d_sequential: ${OFILES} vp4d_sequential.o 
	${FC} ${FFLAGS} -o ${SIM_NAME} $^ -I${SLL_DIR}/include/selalib ${FLIBS}

run: build
	mpirun -np 8 ${SIM_NAME}

clean: 
	rm -f *.o ${SIM_NAME} *.mod

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

