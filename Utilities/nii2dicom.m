[niifile,path] = uigetfile('*.nii');
% Take magnitude
system(['mkdir ',strrep(path,' ','\ '),extractBefore(niifile,'.')]);
cd([path,'/',extractBefore(niifile,'.')]);

data = mat2gray(abs(niftiread([path,niifile])));
dim = size(data);



info.TransferSyntaxUID = '1.2.840.10008.1.2'; % Explicit VR Little Endian
info.SOPClassUID = '1.2.840.10008.5.1.4.1.1.7'; 
info.PhotometricInterpretation = 'MONOCHROME2';
info.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.7'; % 

dicomwrite(reshape(data,[dim(1) dim(2) 1 dim(3)]), [extractBefore(niifile,'.') '.dcm'],info, 'CreateMode', 'Copy', 'MultiframeSingleFile', 'true');

