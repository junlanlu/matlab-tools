function saveas_w(H, fname)
set(H,'Color','w');
F = getframe(H);
F = remove_whitespace(F.cdata);
imwrite(F, fname);
end