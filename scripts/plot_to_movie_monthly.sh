ffmpeg -framerate 15 -pattern_type glob -i "/D/MIT-WHOI/github_repos/plankton-index/results/weekly_rac/*.png" -s:v 1440x1080 -c:v libx264 -crf 17 -pix_fmt yuv420p /D/MIT-WHOI/github_repos/plankton-index/rac_plot_weekly.mp4
