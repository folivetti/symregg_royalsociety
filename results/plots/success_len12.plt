set terminal pdf size 6,3

set datafile separator comma
# format of prepare_ecdf output
# "runnumber,filename,evals,generation,individual_index,expression,fitness,nodes"

load "dark.plt"

esrfolder="/mnt/c/OneDrive\ -\ FH OOe/research/eqsat-symreg-large-files/esr/"
# set output "success_len12.pdf"

set ylabel "P(Fitness>threshold)"
set xlabel "Number of visited expressions"
set xrange[100:50000]
set logscale x
set yrange[0:1]

# thresholds = "0.001 0.005 0.0025 0.001"
# thresholds = "7.354e-3 6.44e-5 2.394e-5"
thresholds = "6.44e-5 2.394e-5"
unset key
set output "beer_len12.pdf"
set multiplot layout 1,2 spacing 0.01  margins 0.10, 0.98, 0.2, 0.8
do for [thr in thresholds] {
     set title "Threshold ". thr
     # set key only for the last threshold
     if (thr == word(thresholds, 1)) {
          set key 
     } else {
          unset key
     }
     plot '< cd ../tinyGP/ && bash prepare_ecdf.sh -'.thr.'  beer_12'        using 3:($1 / 50) with linespoints ls 1 pt 1 title "TinyGP"   at 0.30, 0.95 ,\
          '< cd ../pyoperon_inv/ && bash prepare_ecdf.sh '.thr.' beer_12 12' using 3:($1 / 50) with linespoints ls 4 pt 3 title "pyoperon" at 0.45, 0.95,\
          '< cd ../symregg/ && bash prepare_ecdf.sh '.thr.' beer_12'         using 3:($1 / 50) with linespoints ls 5 pt 4 title "symregg"  at 0.6, 0.95,\
          '< cd "'.esrfolder.'" && bash prepare_ecdf.sh '.thr.' beer_12'     using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"      at 0.75, 0.95

#          '< cd ../egraph-trace/ && bash prepare_ecdf.sh '.thr.' beer_12' using 3:($1 / 50) with linespoints ls 2 pt 2 title "egraph trace",\
#          '< cd ../ESR/ && bash prepare_ecdf.sh '.thr.' beer'             using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"

  unset ylabel
  unset ytics
  unset key
}
unset multiplot


# set title "Success probability plot: Nikuradse 1 / Len=10"
set ylabel "P(Fitness>threshold)"
set xlabel "Number of visited expressions"
set xrange[100:50000]
set yrange[0:1]
set ytics
set output "Niku_1_len12.pdf"
# thresholds="1.656e-3 1.239e-3 9.825e-4"
thresholds="1.239e-3 9.825e-4"
set multiplot layout 1,2 spacing 0.01  margins 0.10, 0.98, 0.2, 0.8
do for [thr in thresholds] {
     set title "Threshold ". thr
     # set key only for the last threshold
     if (thr == word(thresholds, 1)) {
          set key rmargin
     }
     plot '< cd ../tinyGP/ && bash prepare_ecdf.sh -'.thr.' nikuradse_1_12'       using 3:($1 / 50) with linespoints ls 1 pt 1 title "TinyGP"    at 0.35, 0.95 ,\
          '< cd ../pyoperon_inv/ && bash prepare_ecdf.sh '.thr.'  nikuradse_1_12 12'  using 3:($1 / 50) with linespoints ls 4 pt 3 title "pyoperon"  at 0.5, 0.95 ,\
          '< cd ../symregg/ && bash prepare_ecdf.sh '.thr.' nikuradse_1_12'       using 3:($1 / 50) with linespoints ls 5 pt 4 title "symregg"   at 0.65, 0.95 ,\
          '< cd "'.esrfolder.'/nikuradse_1_12/" && bash prepare_ecdf.sh '.thr     using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"      at 0.75, 0.95

#           '< cd ../egraph-trace/ && bash prepare_ecdf.sh '.thr.'  nikuradse_1_12' using 3:($1 / 50) with linespoints ls 2 pt 2 title "egraph trace",\
#          '< cd ../ESR/ && bash prepare_ecdf.sh '.thr.' nikuradse_1'              using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"
     unset ylabel
     unset ytics
     unset key
}
unset multiplot

exit

set terminal pdf size 8,3
set ylabel "P(Fitness>threshold)"
set xlabel "Number of visited expressions"
set xrange[100:50000]
set yrange[0:1]
set output "Niku_2_len12.pdf"
thresholds = "0.0112 4.538e-3 2.174e-3"
set multiplot layout 1,3 spacing 0.01  margins 0.10, 0.98, 0.2, 0.8
do for [thr in thresholds] {
     set title "Threshold " . thr
     # set key only for the last threshold
     if (thr == word(thresholds, 1)) {
          set key 
     } else {
          unset key
     }
     plot '< cd ../tinyGP/ && bash prepare_ecdf.sh -'.thr.' nikuradse_2_12'      using 3:($1 / 50) with linespoints ls 1 pt 1 title "TinyGP"    at 0.35, 0.95 ,\
          '< cd ../pyoperon_inv/ && bash prepare_ecdf.sh '.thr.'  nikuradse_2_12 12' using 3:($1 / 50) with linespoints ls 4 pt 3 title "pyoperon"  at 0.5, 0.95 ,\
          '< cd ../symregg/ && bash prepare_ecdf.sh '.thr.' nikuradse_2_12'      using 3:($1 / 50) with linespoints ls 5 pt 4 title "symregg"   at 0.65, 0.95 ,\
          '< cd "'.esrfolder.'" && bash prepare_ecdf.sh '.thr.' nikuradse_2_12'  using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"      at 0.75, 0.95

          
#           '< cd ../egraph-trace/ && bash prepare_ecdf.sh '.thr.' nikuradse_2_12' using 3:($1 / 50) with linespoints ls 2 pt 2 title "egraph trace",\
#          '< cd ../ESR/ && bash prepare_ecdf.sh '.thr.' nikuradse_2'             using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"
     unset ylabel
     unset ytics
     unset key
}
unset multiplot

#     for [thr in thresholds] '< cd ../egraph-gp/ && bash prepare_ecdf.sh '.thr.' nikuradse_2_10'    using 3:($1 / 50) with linespoints ls 3 title "egraph gp thr = ".thr,\
#     for [thr in " 1.736e-2  8.259e-3  4.812e-3"] '< cd ../operon/ && bash prepare_ecdf.sh -'.thr.' nikuradse_2_5' using 3:($1 / 50) with lines ls 4 title "operon thr = ".thr,\

set ylabel "P(Fitness>threshold)"
set xlabel "Number of visited expressions"
set xrange[100:50000]
set yrange[0:1]
set output "Supernovae_len12.pdf"

thresholds="0.01646 1.875e-3 6.261e-4"
set multiplot layout 1,3 spacing 0.01  margins 0.10, 0.98, 0.2, 0.8
do for [thr in thresholds] {
     set title "Threshold " . thr
     # set key only for the last threshold
     if (thr == word(thresholds, 1)) {
          set key 
     } else {
          unset key
     }
     plot '< cd ../tinyGP/ && bash prepare_ecdf.sh -'.thr.'  supernovae_12'       using 3:($1 / 50) with linespoints ls 1 pt 1 title "TinyGP"    at 0.35, 0.95 ,\
          '< cd ../pyoperon_inv/ && bash prepare_ecdf.sh '.thr.'   supernovae_12 12'  using 3:($1 / 50) with linespoints ls 4 pt 3 title "pyoperon"  at 0.5, 0.95 ,\
          '< cd ../symregg/ && bash prepare_ecdf.sh '.thr.' supernovae_12'        using 3:($1 / 50) with linespoints ls 5 pt 4 title "symregg"   at 0.65, 0.95 ,\
          '< cd "'.esrfolder.'" && bash prepare_ecdf.sh '.thr.' supernovae_12'  using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"      at 0.75, 0.95
          
#           '< cd ../egraph-trace/ && bash prepare_ecdf.sh '.thr.'   supernovae_12' using 3:($1 / 50) with linespoints ls 2 pt 2 title "egraph trace",\
#          '< cd ../ESR/ && bash prepare_ecdf.sh '.thr.' supernovae'               using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"
     unset ylabel
     unset ytics
     unset key
}
unset multiplot
