set terminal pdf
set datafile separator comma

set output "solutions_nikuradse_2.pdf"
tinygp_niku2_10(x0)=(abs(1.2913449897852045)**(abs((x0) / (0.3370812137133396))**(1/(x0)))) + (-0.06667812617181981)
esr_niku2_10(x1)=1/(1.6016660032884702 - abs(x1 * 2.00078591593445902) ** (abs(-0.16810408272463573) ** x1))
esr_niku2_10_v2(x1)=abs(abs(x1) ** (1/x1 + -2.761250710782375) + 1.1223921181958705) ** x1 # 1/0 x1 can become zero
plot '../../datasets/nikuradse_2.csv' using 1:2 with dots title "data",\
     tinygp_niku2_10(x) with lines lw 2 title "tinyGP",\
     esr_niku2_10(x) with lines lw 2 title "ESR",\
     esr_niku2_10_v2(x) with lines lw 2 title "ESR with inv(x1)"
     
     
#################################################     
set output "solutions_nikuradse_1.pdf"
operon_niku1_10(X1,X2) = (((0.018325388432 * X1) ** ((-0.028332995251) * X2)) + (-0.438876807690))
operon_niku1_10_v2(X1,X2)=(0.564137041569 / ((0.020117554814 * X1) ** (0.052544321865 * X2)))
esr_niku1_10(x1,x2)=abs(-0.5200792673286821) ** (abs(abs(x1) ** -0.3006539031394935 + -1.2795516998985128) ** x2)
esr_niku1_10_v2(x1,x2)=x1 / (x2 + 1)
plot '../../datasets/nikuradse_1.csv' using 2:3 with dots title "data",\
     '' using 2:(operon_niku1_10($1,$2)) with dots lw 2 title "operon (10)",\
     '' using 2:(operon_niku1_10_v2($1,$2)) with dots lw 2 title "operon v2 (10)",\
     '' using 2:(esr_niku1_10($1,$2)) with dots lw 2 title "esr",\
     '' using 2:(esr_niku1_10_v2($1,$2)) with dots lw 2 title "esr v2",\
     
     
     
     
     
