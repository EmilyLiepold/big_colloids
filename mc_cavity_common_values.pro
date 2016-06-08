;*********************************************************************************
; NAME:
;   mc_cavity_common_values
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

pro mc_cavity_common_values, outdir, tracks = tracks, sum = sum, $ 
  output_tail=output_tail, cavcent, cavdiam, speed=speed,ratio=ratio, $
  displacement_steps = displacement_steps

compile_opt idl2

if keyword_set(speed) then speed=speed else speed=5. ;frames per second
if keyword_set(ratio) then ratio=ratio else ratio=0.169 ;microns per pixel
if keyword_set(output_tail) then output_tail=output_tail else output_tail='all'
if keyword_set(displacement_steps) then displacement_steps=displacement_steps $
else displacement_steps=30
if ~keyword_set(sum) && ~keyword_set(tracks) then print,'No input provided!'
if keyword_set(sum) then sum = sum
if keyword_set(tracks) then tr = tracks

;Load the sum and tr files
;sum = read_gdf('sum_loc_'+output_tail)
;tr = read_gdf('tr_loc_'+output_tail)

;As a shorthand, sum has length L and tr has length K
L = n_elements(sum[0,*])
K = n_elements(tr[0,*])

;Create the easy values by breaking tr and sum into position, frame, loc, and part arrays. Also make room for rt position arrays.
;sumxy = sum[0:1,*]
sum_pos = reform(complex(sum[0,*], sum[1,*]))
;sumrt = sumxy * 0
sumfr = long(reform(sum[2,*]))
sumloc = fix(reform(sum[3,*]))
;trxy = tr[0:1,*]
tr_pos = reform(complex(tr[0,*],tr[1,*]))
;trrt = trxy * 0
;cavxy = trxy * 0
trfr = long(reform(tr[2,*]))
trpart = long(reform(tr[3,*]))
trloc = fix(reform(tr[4,*]))




;Populate tracking variables, describing whether two consecutive indices are the same particle, track to the following frame, and remain in the same cavity.
trsamepart = ~(shift(trpart,-1) - trpart)
trnextframe = (shift(trfr,-1) - trfr) eq 1

;Make room for displacements.
dxy = make_array(n_elements(trxy[*,0]), n_elements(trxy[0,*]),displacement_steps)
drt = make_array(n_elements(trxy[*,0]), n_elements(trxy[0,*]),displacement_steps)
dxy_comp = make_array(n_elements(trxy[0,*]),displacement_steps, /complex)
drt_comp = make_array(n_elements(trxy[0,*]),displacement_steps, /complex)

;Set variables describing whether the previous index is the same particle in the previous frame. Account for rt tracking needing the particle to stay in the cavity as well. Out of the cavity, r=0.
badlist = trsamepart * trnextframe
badarray = make_array(n_elements(badlist),displacement_steps)

;Set the first displacement.
dxy_comp[*,0] = shift(tr_pos,-1) - tr_pos
drt_comp[*,0] = conj(tr_pos) * dxy_comp[*,0] / abs(tr_pos)
badarray[*,0] = badlist


;Repeat for each displacement_step
for i=1,displacement_steps - 1 do begin
  badarray[*,i] = badarray[*,i-1] * shift(badarray[*,-1],-1,0)
  dxy_comp[*,i] = shift(tr_pos,-i - 1) - tr_pos
  drt_comp[*,i] = conj(tr_pos) * dxy_comp[*,i] / abs(tr_pos)
endfor

;Make room for count variables, holding the number of particles in each cavity in each frame 
sumcount = make_array(max(sumfr)+1, /integer)
 trcount = make_array(max( trfr)+1, /integer)

;Populate count variables
for i = 0, L - 1 do begin
  sumcount[sumfr[i]] += 1
endfor

for i = 0, K - 1 do begin
   trcount[trfr[i]] += 1
endfor

;Calculate Ds by squaring the displacements
Dsxy = complex(real_part(dxy_comp)^2,imaginary(dxy_comp)^2)
Dsrt = complex(real_part(drt_comp)^2,imaginary(drt_comp)^2)

;Divide <dx^2> by time to give the true Ds
for i=0,n_elements(Dsrt[0,0,*])-1 do begin
  Dsrt[*,i] = Dsrt[*,i] / (i + 1.)
  Dsxy[*,i] = Dsxy[*,i] / (i + 1.)
endfor

;Set units
;Dsxy = Dsxy * ratio^2 * speed
;Dsrt = Dsrt * ratio^2 * speed


;Write to disk
write_gdf,sum_pos,outdir+'sumpos'
write_gdf, tr_pos,outdir+ 'trpos'
;write_gdf, sumxy, outdir+'sumxy'
;write_gdf, sumrt, outdir+'sumrt'
write_gdf, sumfr, outdir+'sumfr'
write_gdf,sumloc, outdir+'sumloc'
;write_gdf,  trxy, outdir+'trxy'
;write_gdf,  trrt, outdir+'trrt'
write_gdf,  trfr, outdir+'trfr'
write_gdf, trloc, outdir+'trloc'
write_gdf,trpart, outdir+'trpart'
;write_gdf,sumincav,outdir+'sumincav'
;write_gdf,trincav,outdir+'trincav'
;write_gdf,sumrt,outdir+'sumrt'
;write_gdf,trrt,outdir+'trrt'
write_gdf,trsamepart,outdir+'trsamepart'
write_gdf,trnextframe,outdir+'trnextframe'
write_gdf,badarray,outdir+'badarray'
write_gdf,dxy_comp,outdir+'dxy'
write_gdf,drt_comp,outdir+'drt'
write_gdf,sumcount,outdir+'sumcount'
write_gdf,trcount,outdir+'trcount'
write_gdf,Dsxy,outdir+'Dsxy'
write_gdf,Dsrt,outdir+'Dsrt'
;write_gdf,suminclosed,outdir+'suminclosed'
;write_gdf, trinclosed,outdir+ 'trinclosed'

print,'Common_vals Complete!'

end