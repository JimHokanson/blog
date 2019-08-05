headers = {'Name' 'Computer' 'Favorite Food' 'Favorite Animal'};
data = {
    'Jim'   'Bob'      'Cheese'  'Vulture'
    'Tyler' 'Turtle'   'Pizza' 'Sea Otter'
    'Josh'  'Drumkit'  'Taco Bell Tacos' 'four-headed dragon'
    'Sally Sunshine' 'Speedy' 'Avocado Rolls' 'Liger'};

display_data = sl.gui.cellToListbox(data,'headers',headers,'merge_header',true);

figure
set(gcf,'Units','pixels','Position',[100 100 500 70])
uicontrol(gcf,'Style','listbox','Units','pixels','Position',[0 0 500 70],...
    'String',display_data.row_data,'FontName','FixedWidth');
