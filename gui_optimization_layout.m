%Detection and tracking gui
fi.L=hf.Position(1);
fi.B=hf.Position(2);
fi.W=hf.Position(3);
fi.H=hf.Position(4);

buff.w=max([20,0.025*fi.W]);
buff.h=80;
%xyaxis_w=xyaxis.w
xyaxis_w=(fi.H-2.5*buff.h).*3/4;

minbuff_h=6;
stdbuff_h=2*minbuff_h;
elementsep_h=stdbuff_h;
txtbx_h=25;
rbtn_h=22;
pushbutton_h=30;
txt_h=20;

%Heights
view_tuberb_h=stdbuff_h + rbtn_h + minbuff_h...
    + rbtn_h + minbuff_h + stdbuff_h;

view_tracerb_h=stdbuff_h + rbtn_h + minbuff_h...
    + rbtn_h + minbuff_h...
    + rbtn_h + minbuff_h + stdbuff_h;

view_chnrb_h=stdbuff_h + rbtn_h + minbuff_h...
    + rbtn_h + minbuff_h...
    + rbtn_h + minbuff_h + stdbuff_h;

viewpanel_h =...
    stdbuff_h...
    + elementsep_h...
    + txtbx_h + txt_h + minbuff_h...
    + elementsep_h...
    + view_chnrb_h...
    + elementsep_h...
    + view_tracerb_h...
    + elementsep_h...
    + view_tuberb_h...
    + stdbuff_h;

operationpanel_h=...
    stdbuff_h...
    + 3*(pushbutton_h+minbuff_h)...
    + stdbuff_h;

%Widths
stdbuff_w=20;
element_w=130;
panel_w=element_w+2*stdbuff_w;               %Buffer is on left and right
stdbuff_w=stdbuff_w-2;                       %InnerPosition of panels is 2 pixels away from the Position property

%From Left
panel_l=buff.w;
element_l=stdbuff_w;                         %This is relative to the panel

%From bottom
viewpanel_b=buff.h;
view_tuberb_b=stdbuff_h;
view_tracerb_b=view_tuberb_b + view_tuberb_h + elementsep_h;
view_chnrb_b=view_tracerb_b + view_tracerb_h + elementsep_h;
view_intrange_b=view_chnrb_b + view_chnrb_h + elementsep_h;
operationpanel_b=2*buff.h+(4/3)*xyaxis_w-operationpanel_h;


fi.H=2.5*buff.h+4/3*(xyaxis_w);
fi.W=2*panel_l+panel_w+2*buff.h++4/3*(xyaxis_w);
hf.Position=[fi.L,fi.B,fi.W,fi.H];
