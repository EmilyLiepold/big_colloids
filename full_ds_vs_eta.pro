
;Test

;Test again

pro Full_Ds_vs_eta

  compile_opt idl2


  partdiam = 1.57
  cavdiam = 25
  in_out = 70
  line = .90
  disp = 8
  tail = 'all'
  mainfolder = '/Users/sphere4/Desktop/Molly Chris 2015/Closed Cavity Runs/High_res_rerun/'
  cd,mainfolder

  
  fld = 'T' + strtrim(indgen(100,start=1),2)

  nf = n_elements(fld)
  print,nf

  k = (partdiam / cavdiam)^2

  eta_drt_pair = [0.,0.,0.]
  d_eta_drt_pair = [0.,0.,0.]
  eta_dsrt_pair = [0.,0.,0.]
  d_eta_dsrt_pair = [0.,0.,0.]
  eta_dsrt_in_pair = [0.,0.,0.]
  d_eta_dsrt_in_pair = [0.,0.,0.]
  eta_dsrt_out_pair = [0.,0.,0.]
  d_eta_dsrt_out_pair = [0.,0.,0.]

  
  for m=0,nf-1 do begin

    dir = fld[m]
    print,fld[m]

    trrt = read_gdf(mainfolder + dir + '/common_vals/trrt')
    dsrt = read_gdf(mainfolder + dir + '/common_vals/dsrt')
    trcount = read_gdf(mainfolder + dir + '/common_vals/trcount')
    n_dist =   read_gdf(mainfolder + dir + '/dists/count_dist_' + tail)
    
    w = where(trrt[0,*] lt max(trrt[0,*]) * line, complement = v)
