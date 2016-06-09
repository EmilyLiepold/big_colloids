pro mc_single_cavity_batch_processor, mainmaindir,output_tail

cd,mainmaindir

speed = 1.
ratio = 1.
displacement_steps = 10
cuts = [0.25,0.5,0.75]
step = 3


infolders = file_search('T*')


for i = 0, n_elements(infolders)-1 do begin


mc_single_cavity_batch, mainmaindir+infolders+'/', output_tail,speed=speed,ratio=ratio, $
    displacement_steps=displacement_steps, cuts, step







endfor





end