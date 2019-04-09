function res = Analysis_Utils_Calculate_Residual(x,y)
    fitvars = polyfit(x,y,1);
    res = y - (fitvars(1) * x+ fitvars(2));
end