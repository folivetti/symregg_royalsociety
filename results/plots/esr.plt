set terminal pdf
extension='.pdf'

# set terminal cairolatex pdf input  size 6cm,4cm header "\\footnotesize"
# extension=".tex"

set datafile separator ';'
# set key autotitle columnhead # skip first line

set xlabel 'Fraction of expressions'
set ylabel 'MSE'

set logscale x
set logscale y
set format x "%g"
set xtics 1e-6,10,1   # 212595 rows
set yrange [1e-6:1]

########################
# Beer
########################
set key top left
# nll over rank
set output 'plots/beer_len10_distr' . extension
file_beer_10='< mlr --fs ";" --csv --implicit-csv-header --headerless-csv-output --from esr/beer/ranked_mse_len10.txt.gz cut -f 3 then cat -n' # number lines
# set xrange[-1000:700]

# beer simple solutions:
# database_nvar1_len_10_fitted.txt.gz;inv(p1 - abs(p2) ^ (abs(p3) ^ x1)) * x1;2.4626552756129027e-5;[2.561427872157478, -0.9951557475796443, 2.2622914856094245];5093;5092;25;195;0;25;0.548622301
# database_nvar1_len_10_fitted.txt.gz;x1 / (p1 - abs(p2) ^ -(abs(p3) ^ x1));2.4626552756129552e-5;[2.5614278720926453, -1.004867833461794, -2.2622914834870285];17000;16999;141;42;0;55;3.2604534960000002
# database_nvar1_len_10_fitted.txt.gz;x1 / (p1 - abs(p2) ^ (abs(p3) ^ -x1));2.4626552756131205e-5;[2.5614278691106978, -0.9951557474729882, 0.44202968893298095];22444;22443;158;62;0;43;2.230777888
# database_nvar1_len_9_fitted.txt.gz;x1 / (p1 - abs(p2) ^ (abs(p3) ^ x1));2.4626552756136874e-5;[2.5614278723303943, -0.9951557476074719, -2.262291483051191];4583;4582;21;199;0;21;0.823784842

stats file_beer_10 using 1:2 name 'beer' nooutput
# set arrow 1 from 0.06,0.06301759103812457 to 1,0.06301759103812457 nohead dt '.'
# set label 1 "$p_1$" at 0.8,0.07 right
# set arrow 2 from 0.006,0.01884 to 1,0.01884 nohead dt '.'
# set label 2 "$p_1^{x p_2^x}$" at 0.8, 0.026  right
plot file_beer_10 using ($1/(beer_records + beer_outofrange)):2 with lines title "Beer ESR (len 10)"


########################
# Beerlaw
########################
set output 'plots/beerlaw_len10_distr' . extension
file_beerlaw_10='< mlr --fs ";" --csv --implicit-csv-header --headerless-csv-output --from esr/beerlaw/ranked_mse_len10.txt.gz cut -f 3 then cat -n' 

stats file_beerlaw_10 using 1:2 name 'beerlaw' nooutput
plot file_beerlaw_10 using ($1/(beerlaw_records + beerlaw_outofrange)):2 with lines title "Beerlaw ESR (len 10)"



########################
# Supernovae
########################
set yrange[0.0001:2]
set output 'plots/supernovae_len10_distr' . extension
file_supernovae_10='< mlr --fs ";" --csv --implicit-csv-header --headerless-csv-output --from esr/supernovae/ranked_mse_len10.txt.gz cut -f 3 then cat -n' 

stats file_supernovae_10 using 1:2 name 'supernovae' nooutput
plot file_supernovae_10 using ($1/(supernovae_records + supernovae_outofrange)):2 with lines title "Supernovae ESR (len 10)"



########################
# Nikuradse_1 (2 dim)
########################
set yrange[5e-4:1]
unset xrange # this dataset contains 2078509 rows
set output 'plots/nikuradse1_len10_distr' . extension
file_nikuradse1_10='< mlr --csv --fs ";" --implicit-csv-header --from esr/nikuradse_1_10/ranked_mse_len10.txt.gz cat -n then cut -f n,3'  # this was prepared with mlr to contain only the two relevant rows already

stats file_nikuradse1_10 using 1:2 name 'nikuradse1' nooutput
plot file_nikuradse1_10 using ($1/(nikuradse1_records + nikuradse1_outofrange)):2 with lines title "Nikuradse 1 (2 dim) ESR (len 10)"



########################
# Nikuradse_2 (1 dim)
########################
set yrange[0.001:1]
set output 'plots/nikuradse2_len10_distr' . extension
file_nikuradse2_10='< mlr --fs ";" --csv --implicit-csv-header --headerless-csv-output --from esr/nikuradse_2/ranked_mse_len10.txt.gz cut -f 3 then cat -n' 

stats file_nikuradse2_10 using 1:2 name 'nikuradse2' nooutput
plot file_nikuradse2_10 using ($1/(nikuradse2_records + nikuradse2_outofrange)):2 with lines title "Nikuradse 2 (1 dim) ESR (len 10)"



quit
