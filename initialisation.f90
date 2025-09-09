!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! initialisation.f90  --- Initialisation des valeurs.
!!                 Calcul de la solution exacte u_exact et du second membre f.
!!
!! Auteur          : Isabelle DUPAYS (CNRS/IDRIS - France)
!!                   <Isabelle.Dupays@idris.fr>
!! Cree le         : Fri Nov 15 10:32:45 1996
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!*******************************************************************
SUBROUTINE initialisation( u, u_nouveau, f, u_exact, ntx, h, sx, sy, ex, ey)
  !*****************************************************************

  USE prec_mod

  IMPLICIT NONE

  !--Declaration des variables

  !Nombre de points total
  INTEGER                               :: ntx
  !Borne inferieure et superieure en x
  INTEGER                               :: sx, ex
  !Borne inferieure et superieure en y
  INTEGER                               :: sy, ey
  !Solution u et u_nouveau a l'iteration n et n+1
  REAL(kind=rp), DIMENSION(sx-1:, sy-1:) :: u, u_nouveau
  !Second membre
  REAL(kind=rp), DIMENSION(sx-1:, sy-1:) :: f
  !Solution exacte
  REAL(kind=rp), DIMENSION(sx-1:, sy-1:) :: u_exact
  !Compteurs
  INTEGER                               :: i,j
  !Coordonnees globales suivant x et y
  REAL(kind=rp)                          :: x,y
  !Pas
  REAL(kind=rp)                          :: h

  !*****************************************************************

  !Initialisation des matrices
  u(:,:)         = 0.
  u_nouveau(:,:) = 0.
  f(:,:)         = 0.
  u_exact(:,:)   = 0.

  !Pas
  h = 1./real(ntx+1)

  !Initialisation du second membre et calcul de la solution exacte
  DO i=sx,ex
     DO j=sy,ey
        x = i*h
        y = j*h
        f(i,j) = 2*(x*x-x+y*y-y)
        u_exact(i,j) = x*y*(x-1)*(y-1)
     END DO
  END DO

END SUBROUTINE initialisation
