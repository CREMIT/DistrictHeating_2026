function positivePart
    "Smooth approximation to max(u,0)"
    input Real u;
    input Real delta(min=1e-9)=1e-4;
    output Real y;
  algorithm
    y := 0.5*(u + sqrt(u*u + delta*delta));
end positivePart;
