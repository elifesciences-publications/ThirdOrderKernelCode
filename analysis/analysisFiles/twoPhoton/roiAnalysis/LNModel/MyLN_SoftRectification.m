function y = MyLN_SoftRectification(x,soft_rectification_coe)

A = soft_rectification_coe.A;
B = soft_rectification_coe.B;
r0 = soft_rectification_coe.r0;
r1 = soft_rectification_coe.r1;

y = A + B * log(1 + exp((x - r0)/r1));
end
