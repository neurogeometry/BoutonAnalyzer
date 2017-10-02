function [] = customizeMenus(hf)
%These functions removes extra menus from the matlab figure, and assigns
%the custom Help menu to gui_optimization and gui_alignment

menuhandles = findall(hf,'type','uimenu','-regexp','Tag','(figMenu)');
set(menuhandles,'Visible','off');

alltools=findall(hf,'type','uitoggletool');
set(alltools,'Visible','off');

alltools=findall(hf,'Type','uipushtool');
set(alltools,'Visible','off');

keeptools=findall(hf,'-regexp','Tag','(Exploration.)');
set(keeptools,'Visible','on');

allsep=findall(hf,'Separator','On');
set(allsep,'Separator','off');

hfmenu=uimenu('Label','Settings','Parent',hf);
uimenu(hfmenu,'Label','Open Parameter File','Callback','open(''paramset'')');

workingdir=pwd;
cbfcn=['open(''',workingdir,filesep,'User Manual.pdf'')'];
hfmenu=uimenu('Label','Help','Parent',hf);
uimenu(hfmenu,'Label','User Manual','Callback',cbfcn);
uimenu(hfmenu,'Label','Website','Callback','web(''http://www.northeastern.edu/neurogeometry/resources/bouton-analyzer/'')');
end