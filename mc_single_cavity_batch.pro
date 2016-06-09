pro mc_single_cavity_batch, maindir, output_tail,speed=speed,ratio=ratio, $
displacement_steps=displacement_steps, cuts, step

cd,maindir

sumfile = file_search('sum_loc_*')
if sumfile eq '' then sumdata = !Null
trfile = file_search('tr_loc_*')
if trfile eq '' then trfile = !Null

valdir = maindir + 'common_vals/'


mc_single_cavity_common_vals, valdir, tracks = trfile, sum = sumfile, $
  output_tail=output_tail, speed=speed,ratio=ratio, $
  displacement_steps = displacement_steps
  
mc_single_cavity_ring_diffusion,maindir, valdir, output_tail=output_tail, $
    displacement_step = step,cuts
    
    
end