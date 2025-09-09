!**********************************************************************
!   poisson.f90 - Resolution de l'equation de Poisson en utilisant Jacobi
!   sur le domaine [0,1]x[0,1] par une methode aux differences finies,
!   avec comme solveur Jacobi.
!   Delta u = f(x,y)= 2*(x*x-x+y*y -y)
!   u sur les bords vaut 0
!   La solution exacte est u= x*y*(x-1)*(y-1)
!
!   La valeur de u est donnee par la formule:
!   u(i,j)(n+1) = 0.25*(u(i+1,j)(n)+u(i-1,j)(n) +
!                       u(i,j+1)(n)+u(i,j-1)(n) - h*h*f(i,j))
!
!   Dans cette version, on se donne le nombre de points interieurs
!   total suivant x (ntx) et le nombre de points interieurs total
!   suivant y (nty).
!   ntx = nty
!
!   hx represente le pas suivant x, hy le pas suivant y, comme
!   ntx = nty , hx=hy=h=1/(ntx+1)
!****************************************************************************

PROGRAM poisson

  USE prec_mod
  USE interface_mod

#define Nelem_x (ex-sx+1)
#define Nelem_y (ey-sy+1)

#define Nelem_total_x (Nelem_x + 2)
#define Nelem_total_y (Nelem_y + 2)

#define Nelem Nelem_total_x*Nelem_total_y 

  IMPLICIT  NONE

  !---Declaration des variables

  !Solution u et u_nouveau a l'iteration n et n+1 et second membre
  REAL(kind=rp), DIMENSION(:,:), ALLOCATABLE :: u, u_nouveau, f
  !Solution exacte
  REAL(kind=rp), DIMENSION(:,:), ALLOCATABLE :: u_exact
  !Nombre total de points interieurs suivant x et y
  INTEGER                                   :: ntx, nty
  !Borne inferieure et superieure en x
  INTEGER                                   :: sx, ex
  !Borne inferieure et superieure en y
  INTEGER                                   :: sy, ey
  !Pas
  REAL(kind=rp)                             :: h
  !Numero du sous domaine
  INTEGER                                   :: rang, rang_ds_topo
  !Nombre de processus
  INTEGER                                   :: nb_procs
  !Tableau contenant les voisins du sous domaine courant
  INTEGER, PARAMETER                        :: NB_VOISINS = 4
  INTEGER, DIMENSION(NB_VOISINS)            :: voisin
  INTEGER, PARAMETER                        :: N=1, E=2, S=3, W=4
  !Nombre iterations en temps
  INTEGER                                   :: it
  !Nombre iterations maximum en temps
  INTEGER                                   :: it_max
  !Mesure du temps
  INTEGER                                   :: t1, t2, ir
  !Compteur
  INTEGER                                   :: i, j, gpuid
  !Critere de convergence
  REAL(kind=rp), PARAMETER                   :: epsi = 1.D-12
 
  INTEGER, PARAMETER                        :: ifreq = 10000

  REAL(kind=4)                              :: temps

  !****************************************************************************

  OPEN(unit=10,file = 'poisson.data')
  READ(10,*) ntx 
  READ(10,*) it_max
  CLOSE(unit=10)
  nty = ntx 
  
  sx = 1
  sy = 1 
  ex = ntx
  ey = nty

  !Allocation dynamique des tableaux u, u_nouveau, u_exact, f
  ALLOCATE ( u(sx-1:ex+1,  sy-1:ey+1), u_nouveau(sx-1:ex+1, sy-1:ey+1) )
  ALLOCATE ( f(sx-1:ex+1, sy-1:ey+1), u_exact(sx-1:ex+1, sy-1:ey+1) )

  !Initialisation du second membre et de la solution u sur les bords
  CALL initialisation( u, u_nouveau, f, u_exact, ntx, h, sx, sy, ex, ey )

  !Schema iteratif en temps
  it = 0

  !Mesure du temps en seconde dans la boucle en temps
  call system_clock(count=t1, count_rate=ir)

!$omp target enter data map(to: u, u_nouveau, f)

  DO WHILE (it < it_max)

!!$omp target teams distribute parallel do collapse(2)
!$omp target teams loop collapse(2)
     DO j = sy, ey
         DO i = sx, ex
              u_nouveau(i,j) = 0.25 * ( u(i-1,j) + u(i,j+1) + u(i,j-1) + u(i+1,j) &
                                              - h*h*f(i,j) )
         END DO
     END DO

!!$omp target teams distribute parallel do collapse(2)
!$omp target teams loop collapse(2)
     DO j = sy, ey
        DO i = sx, ex
             u(i,j) = 0.25 * ( u_nouveau(i-1,j) + u_nouveau(i,j+1) + u_nouveau(i,j-1) + u_nouveau(i+1,j) &
                                      - h*h*f(i,j) )
        END DO
     END DO 

     it = it + 2

     !Affichage pour un processus de l'iteration
     IF ( MOD(it,ifreq) == 0 ) THEN
        PRINT '(a,i)', 'Iteration', it
     END IF

  END DO ! WHILE

!$omp target exit data map(from: u) map(delete: u_nouveau,f)

  !Mesure du temps a la sortie de la boucle
  call system_clock(count=t2, count_rate=ir)

  temps = real(t2 - t1, kind=4) / real(ir,kind=4)

  !Affichage du temps machine par le processus 0 
     PRINT *, ''
     PRINT *, 'Performance : ', it, ' iterations in  ', temps, ' secs '
     PRINT *, ''
     PRINT *, 'Numerical results in fort.100'

  !Comparaison de la solution calculee et de la solution exacte
     WRITE (100,'(2a,i4,a)') 'Exact solution u_exact   ', 'Computed solution u'

     DO i = sx, ex
        WRITE(100, 10) u_exact(i,sy), u(i,sy)
     END DO

10   FORMAT ('u_exact =  ', E12.5, '    u =  ', E12.5)

  !Desallocation des tableaux u,u_nouveau,u_exact et f
  DEALLOCATE(u, u_nouveau, u_exact, f)

END PROGRAM poisson
