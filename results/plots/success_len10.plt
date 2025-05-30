set terminal pdf size 8,3

set datafile separator comma
# format of prepare_ecdf output
# "runnumber,filename,evals,generation,individual_index,expression,fitness,nodes"

load "dark.plt"

# set output "success_len10.pdf"

set title "Success probability plot: Beer / Len=10"
set ylabel "P(Fitness>threshold)"
set xlabel "Number of visited expressions"
set xrange[1:50000]
set logscale x
set yrange[0:1]

# thresholds = "1.505e-3 1.866e-4 5.652e-5"
thresholds = "1.866e-4 5.652e-5"
unset key

set output "beer_len10.pdf"
set multiplot layout 1,2 spacing 0.01  margins 0.10, 0.98, 0.2, 0.8
do for [thr in thresholds] {
     set title "Threshold " . thr
     # set key only for the first threshold
     if (thr == word(thresholds, 1)) {
          set key 
     } else {
          unset key
     }
     plot '< cd ../tinyGP/ && bash prepare_ecdf.sh -'.thr.'  beer_10'     using 3:($1 / 50) with linespoints ls 1 pt 1 title "TinyGP"   at 0.30, 0.95 ,\
          '< cd ../pyoperon_inv/ && bash prepare_ecdf.sh '.thr.' beer_10 10'  using 3:($1 / 50) with linespoints ls 4 pt 3 title "pyoperon" at 0.45, 0.95,\
          '< cd ../symregg/ && bash prepare_ecdf.sh '.thr.' beer_10'      using 3:($1 / 50) with linespoints ls 5 pt 4 title "symregg"  at 0.6, 0.95,\
          '< cd ../esr/ && bash prepare_ecdf.sh '.thr.' beer'             using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"      at 0.75, 0.95

  unset ylabel
  unset ytics
  unset key
}
unset multiplot


#          '< cd ../egraph-trace/ && bash prepare_ecdf.sh '.thr.' beer_10' using 3:($1 / 50) with linespoints ls 2 pt 2 title "egraph trace",\
#     for [thr in thresholds] '< cd ../egraph-gp/ && bash prepare_ecdf.sh '.thr.' beer_10'    using 3:($1 / 50) with linespoints ls 3 title "egraph gp thr = ".thr ,\
#     for [thr in "1.505e-3 1.866e-4 5.652e-5"] '< cd ../operon/ && bash prepare_ecdf.sh -'.thr.' beer_5' using 3:($1 / 50) with lines lc 4 title "operon thr = ".thr ,\

# set title "Success probability plot: Nikuradse 1 / Len=10"
set ylabel "P(Fitness>threshold)"
set xlabel "Number of visited expressions"
set xrange[1:50000]
set yrange[0:1]
set ytics
set output "Niku_1_len10.pdf"
# thresholds=" 1.570e-2  1.296e-3  1.090e-3  9.759e-4"
# thresholds="1.296e-3  1.090e-3  9.759e-4"
thresholds="0.0013  0.001071 0.000958"
set multiplot layout 1,3 spacing 0.01  margins 0.10, 0.98, 0.2, 0.8
do for [thr in thresholds] {
     set title "Threshold ". thr
     # set key only for the last threshold
     if (thr == word(thresholds, 1)) {
          set key 
     } else {
          unset key
     }
     plot '< cd ../tinyGP/ && bash prepare_ecdf.sh -'.thr.' nikuradse_1_10'       using 3:($1 / 50) with linespoints ls 1 pt 1 title "TinyGP"   at 0.30, 0.95 ,\
          '< cd ../pyoperon_inv/ && bash prepare_ecdf.sh '.thr.'  nikuradse_1_10 10'  using 3:($1 / 50) with linespoints ls 4 pt 3 title "pyoperon" at 0.45, 0.95,\
          '< cd ../symregg/ && bash prepare_ecdf.sh '.thr.' nikuradse_1_10'       using 3:($1 / 50) with linespoints ls 5 pt 4 title "symregg"  at 0.6, 0.95,\
          '< cd ../esr/ && bash prepare_ecdf.sh '.thr.' nikuradse_1_10'              using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"      at 0.75, 0.95
     unset ylabel
     unset ytics
     unset key
}
unset multiplot
#      for [thr in thresholds] '< cd ../egraph-gp/ && bash prepare_ecdf.sh '.thr.'  nikuradse_1_10'    using 3:($1 / 50) with linespoints ls 3 title "egraph gp thr = ".thr ,\
#          '< cd ../egraph-trace/ && bash prepare_ecdf.sh '.thr.'  nikuradse_1_10' using 3:($1 / 50) with linespoints ls 2 pt 2 title "egraph trace",\
     # for [thr in " 1.570e-2  1.296e-3  1.090e-3  9.759e-4"] '< cd ../operon/ && bash prepare_ecdf.sh -'.thr.'  nikuradse_1_5' using 3:($1 / 50) with lines ls 4 title "operon thr = ".thr ,\
       
       
set ylabel "P(Fitness>threshold)"
set xlabel "Number of visited expressions"
set xrange[1:50000]
set yrange[0:1]
set output "Niku_2_len10.pdf"
thresholds = " 1.736e-2  8.259e-3  4.812e-3"
set multiplot layout 1,3 spacing 0.01  margins 0.10, 0.98, 0.2, 0.8
do for [thr in thresholds] {
     set title "Threshold " . thr
     # set key only for the last threshold
     if (thr == word(thresholds, 1)) {
          set key 
     } else {
          unset key
     }
     plot '< cd ../tinyGP/ && bash prepare_ecdf.sh -'.thr.' nikuradse_2_10'      using 3:($1 / 50) with linespoints ls 1 pt 1 title "TinyGP"   at 0.30, 0.95 ,\
          '< cd ../pyoperon_inv/ && bash prepare_ecdf.sh '.thr.'  nikuradse_2_10 10' using 3:($1 / 50) with linespoints ls 4 pt 3 title "pyoperon" at 0.45, 0.95,\
          '< cd ../symregg/ && bash prepare_ecdf.sh '.thr.' nikuradse_2_10'      using 3:($1 / 50) with linespoints ls 5 pt 4 title "symregg"  at 0.6, 0.95,\
          '< cd ../esr/ && bash prepare_ecdf.sh '.thr.' nikuradse_2'             using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"      at 0.75, 0.95
     unset ylabel
     unset ytics
     unset key
}
unset multiplot

#          '< cd ../egraph-trace/ && bash prepare_ecdf.sh '.thr.' nikuradse_2_10' using 3:($1 / 50) with linespoints ls 2 pt 2 title "egraph trace",\
#     for [thr in thresholds] '< cd ../egraph-gp/ && bash prepare_ecdf.sh '.thr.' nikuradse_2_10'    using 3:($1 / 50) with linespoints ls 3 title "egraph gp thr = ".thr,\
#     for [thr in " 1.736e-2  8.259e-3  4.812e-3"] '< cd ../operon/ && bash prepare_ecdf.sh -'.thr.' nikuradse_2_5' using 3:($1 / 50) with lines ls 4 title "operon thr = ".thr,\

set ylabel "P(Fitness>threshold)"
set xlabel "Number of visited expressions"
set xrange[1:50000]
set yrange[0:1]
set output "Supernovae_len10.pdf"
thresholds=" 1.663e-2  1.837e-3  7.155e-4"
set multiplot layout 1,3 spacing 0.01  margins 0.10, 0.98, 0.2, 0.8
do for [thr in thresholds] {
     set title "Threshold " . thr
     # set key only for the last threshold
     if (thr == word(thresholds, 1)) {
          set key 
     } else {
          unset key
     }
     plot '< cd ../tinyGP/ && bash prepare_ecdf.sh -'.thr.'  supernovae_10'       using 3:($1 / 50) with linespoints ls 1 pt 1 title "TinyGP"   at 0.30, 0.95 ,\
          '< cd ../pyoperon_inv/ && bash prepare_ecdf.sh '.thr.'   supernovae_10 10'  using 3:($1 / 50) with linespoints ls 4 pt 3 title "pyoperon" at 0.45, 0.95,\
          '< cd ../symregg/ && bash prepare_ecdf.sh '.thr.' supernovae_10'        using 3:($1 / 50) with linespoints ls 5 pt 4 title "symregg"  at 0.6, 0.95,\
          '< cd ../esr/ && bash prepare_ecdf.sh '.thr.' supernovae'               using 2:($1 / 50) with linespoints ls 6 pt 6 title "ESR"      at 0.75, 0.95
     unset ylabel
     unset ytics
     unset key
}
unset multiplot

#           '< cd ../egraph-trace/ && bash prepare_ecdf.sh '.thr.'   supernovae_10' using 3:($1 / 50) with linespoints ls 2 pt 2 title "egraph trace",\
#     for [thr in thresholds] '< cd ../egraph-gp/ && bash prepare_ecdf.sh '.thr.'   supernovae_10'    using 3:($1 / 50) with linespoints ls 3 title "egraph gp thr = ".thr,\
#     for [thr in " 1.663e-2  1.837e-3  7.155e-4"] '< cd ../operon/ && bash prepare_ecdf.sh -'.thr.'   supernovae_5' using 3:($1 / 50) with lines ls 4 title "operon thr = ".thr,\

    