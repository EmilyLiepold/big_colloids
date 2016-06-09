;*********************************************************************************
; NAME:
;   mc_cavity_common_vals
;VERSION:
;   1.0
; PURPOSE:
;   Calculate the quantities to be used for further programs. This program
;   generates these quantities from a single cavity centered at the origin.
;CATEGORY:
;   Data Processing
; CALLING SEQUENCE:
;   mc_common_values, outdir
; INPUTS:
; outdir: Directory to place the resulting files
;
;OPTIONAL PARAMETERS:
; tracks: Array containing trackfile data
; sum: array containing sumdata
; output_tail: tag to describe the set of processed values. Default is 'all'
; speed: Framerate of the input file in frames / second. Default is 5
; ratio: microns / pixel resolution of the video. Default is 0.169
; sigma: Diameter of particles in microns. Default is 1.57
; displacement_steps: number of steps to generate tracks

; OUTPUTS:
;   Many files. See list later
; SIDE EFFECTS:
;   None
; RESTRICTIONS:
;   None
; MODIFICATION HISTORY:
;   Written by Chris Liepold and Molly Wolfson, 2016
;********************************************************************************

pro mc_single_cavity_ring_diffusion,maindir, valdir,  $
  output_tail=output_tail, $
  displacement_step = displacement_step,cuts,nframes = nframes

  if keyword_set(nframes) then nframes = nframes else begin
    trfr = read_gdf(valdir+'trfr')
    nframes = max(trfr)
  endif
  
  dsrt = read_gdf(valdir+'Dsrt')
  tr = read_gdf(valdir+'trpos')  
  maxr = max(abs(tr))
  cuts = [0.,cuts,1.]
  rcuts = maxr * cuts
  
  cutindices = list(length=0)
  cutcounts = [0.]
  dsrt_means = [0.]
  for i=0,n_elements(cuts)-2 do begin
    icut = rcuts[i]
    ocut = rcuts[i+1]
    w = where((abs(tr[*]) ge icut) && (abs(tr[*]) lt ocut),count)
    if count eq 0 then w = 0
    cutindices.add,w
    cutcounts = [cutcounts,count]
    if count gt 0 then dsrt_means = [dsrt_means,mean(dsrt[w])]
  endfor
  
   
   rcutcounts = cutcounts[1:-1] / nframes
   eta = rcutcounts * 0.
   for j = 0,n_elements(cutcounts) - 1 do begin
    eta[j] = rcutcounts[j] / (!pi *(rcuts[j+1]^2 - rcuts[j]^2))
   endfor
   dsrt_means = dsrt_means[1:-1]
   
   out = [[cuts[0:-2]],[cuts[1:-1]],cutcounts,rcutcounts,eta,dsrt_means]

   write_gdf,out,maindir + 'ring_calc'
  
  
  
  
  
  
  
  
  
  
  
  end