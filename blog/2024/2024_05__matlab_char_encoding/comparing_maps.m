bytes = uint8(1:255);

%Note, windows-1252 is a 1 byte map so it is rather efficient
%to do a lookup.

temp = native2unicode(bytes,"windows-1252");
b2 = double(temp);
b3 = double(bytes);

char_map = uint16(temp);

random_text = randi([40,200],1,1e6,'uint8');

tic
convert1 = native2unicode(random_text,"windows-1252");
toc

tic
convert2 = char_map(random_text);
toc