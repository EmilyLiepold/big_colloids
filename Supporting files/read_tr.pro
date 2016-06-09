pro read_tr,dir

cd,dir,current=old_dir

fls = file_search('D*')
fld = file_search('T*')
numdump = n_elements(fls)

for dmp = 0, numdump -1 do begin
  print,'Reading ' + fls[dmp]
  xyz = dir + fls[dmp]
  n = (rascii(xyz,num_records=1))[0]
;  n = (fix(n.field1))[0]
  g = read_xyz(xyz)

  length = n_elements(g[0,*])

  nframes = max(g[5,*])+1

  out = fltarr(4,length)
  out[0:1,*] = g[0:1,*]
  out[2,*] = g[5,*]

  l = indgen(nframes, /long)

  for i=0,n-1 do begin

    r = l * 0.
    r = (l)* n + i

;    if i eq 100 then print,r


    out[3,r] = i

  endfor
  
    new_out = make_array(n_elements(out[*,0]),2)
    n_parts = max(out[3,*])
    for j=0,n_parts do begin
      w = where(out[3,*] eq j)
      new_out = [[new_out],[out[*,w]]]
    endfor
    new_out = new_out[*,2:*] 
  
  cd,fld[dmp],current=back
  write_gdf,new_out,'trackfl_all_0'
  cd,back
  print,'Saved to ' + fld[dmp]
endfor

cd,old_dir


end


