
F90 = amdflang

LD = $(F90) 

OPTIM = -O3

OMPTARGET= -fopenmp --offload-arch=gfx90a 

FFLAGS = $(OMPTARGET) $(PREPROC) $(OPTIM) $(MISC)

LDFLAGS = $(OMPTARGET) $(OPTIM) 

SRC = initialisation.f90 mod_interface.f90 mod_prec.f90 poisson.f90

OBJS = $(SRC:.f90=.o)

EXE = poisson

all: $(EXE)

.SUFFIXES: .o .f90

.f90.o :
	$(F90) $(FFLAGS) -c $<

$(EXE) : $(OBJS)
	mkdir -p bin
	$(LD) $(LDFLAGS) -o bin/$(EXE) $(OBJS)

clean:
	rm -f bin/$(EXE) $(OBJS) *.mod

# Dependencies
mod_prec.o       : mod_prec.f90
poisson.o        : mod_prec.o mod_interface.o poisson.f90 
communication.o  : mod_prec.o communication.f90
domaine.o        : domaine.f90 
initialisation.o : mod_prec.o initialisation.f90
poisson.o        : mod_prec.o poisson.f90 
voisinage.o      : voisinage.f90
mod_interface.o  : mod_prec.o mod_interface.f90
