f = figure();
p = uix.TabPanel( 'Parent', f, 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
uicontrol( 'Parent', p, 'Background', 'b' );
uicontrol( 'Parent', p, 'Background', 'g' );
p.TabTitles = {'Red', 'Blue', 'Green'};
p.Selection = 2;
p.TabEnables = {'on','off','off'};