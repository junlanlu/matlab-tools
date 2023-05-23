function img_nowhite = remove_whitespace(img)
% REMOVE_WHITESPACE takes in 2D data img associated with a figure
% and returns 2D data with the bordering whitespace cropped
    [row, col] = find(img(:,:,1)<255);
    x1 = min(col);
    x2 = max(col);
    y1 = min(row);
    y2 = max(row);
    img_nowhite = img(y1:y2,x1:x2,:);
    
    
end