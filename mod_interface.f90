module interface_mod

interface

 SUBROUTINE initialisation( u, u_nouveau, f, u_exact, ntx, h, sx, sy, ex, ey )
   use prec_mod
   real(kind=rp), dimension(:,:), intent(out)   :: u
   real(kind=rp), dimension(:,:), intent(out)   :: u_nouveau
   real(kind=rp), dimension(:,:), intent(out)   :: f,u_exact
   real(kind=rp), intent(out)                   :: h
   integer, intent(in)                         :: ntx
   integer, intent(in)                         :: sx,sy,ex,ey
 end subroutine initialisation

end interface

end module interface_mod
