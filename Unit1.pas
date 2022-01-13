unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Ani,
  FMX.Objects, FMX.Layouts, FMX.StdCtrls, FMX.Controls.Presentation;

type
  TForm1 = class(TForm)
    LayoutWorld: TLayout;
    LayoutBird: TLayout;
    Ellipse1: TEllipse;
    Ellipse2: TEllipse;
    Circle1: TCircle;
    Circle2: TCircle;
    Pie1: TPie;
    FloatAnimation1: TFloatAnimation;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    FloatAnimation2: TFloatAnimation;
    FloatAnimation3: TFloatAnimation;
    LayoutMessage: TLayout;
    MaxPointLabel: TLabel;
    PointLabel: TLabel;
    StartButton1: TButton;
    Rectangle3: TRectangle;
    ColorAnimation1: TColorAnimation;
    procedure FloatAnimation1Process(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LayoutWorldMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FloatAnimation3Finish(Sender: TObject);
    procedure StartButton1Click(Sender: TObject);
    procedure LayoutBirdPainting(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Reset;
    procedure WayMaker(const aMaster:TLayout);
    procedure GameOver;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
const MaxAbstand:Single =200;
MaxHinder:Integer=5;

procedure TForm1.FloatAnimation1Process(Sender: TObject);
var
I,K:Integer;
C:TLayout;
R:TRectF;
begin

With LayoutBird
	do begin
		if Position.X <> (LayoutWorld.Width -Width)*0.5
		then Position.X :=(LayoutWorld.Width -Width)*0.5;

		if LayoutWorld.AbsoluteRect.Bottom >AbsoluteRect.Bottom
		then Position.Y:=Position.Y+RotationAngle*0.1
    else
    begin
     FloatAnimation1.StopAtCurrent;
     GameOver;
     Exit;
    end;
    R:=AbsoluteRect;
	end;


if Not LayoutWorld.HitTest then Exit;

for I:=0 to LayoutWorld.ChildrenCount-1
do begin
	if Not (LayoutWorld.Children[I] is TLayout) then Continue;
	C:=TLayout(LayoutWorld.Children[I]);
	if C=LayoutBird  then Continue;


  if C.AbsoluteRect.IntersectsWith(R) And (C.Tag=0) //Puan artan yer
  then begin
	C.Tag:=1;
	StartButton1.Tag:=StartButton1.Tag +1;
	PointLabel.Text:=IntToStr(StartButton1.Tag);
  end ;


  if TRectangle(C.Children[0]).AbsoluteRect.IntersectsWith(R)
    or TRectangle(C.Children[1]).AbsoluteRect.IntersectsWith(R)
	then for K:=0 To LayoutBird.ChildrenCount-1
		do if LayoutBird.Children[K] is TControl
			then begin
				R:=TLayout(LayoutBird.children[K]).AbsoluteRect;
				if TRectangle(C.Children[0]).AbsoluteRect.IntersectsWith(R)
				 or TRectangle(C.Children[1]).AbsoluteRect.IntersectsWith(R)
					then begin
						LayoutWorld.HitTest:=False;
            ColorAnimation1.Start;
						Exit;
					end;
			end;

	if C.Position.X+Layout1.Width <0
	then begin
  C.Position.X:=MaxHinder * (Layout1.Width+MaxAbstand)-LayoutBird.Width;
  WayMaker(C);

	end
	else C.Position.X:=C.Position.X - 3;
end;


end;

procedure TForm1.FloatAnimation3Finish(Sender: TObject);
begin
FloatAnimation2.Start;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
P:Single;
C:TLayout;
I:Integer;

begin

LayoutWorld.HitTest:=True;
LayoutWorld.Tag:=0;
P:=LayoutWorld.Width;
Layout1.Position.X:=P;

for I:=2 to MaxHinder
do begin
	C:=TLayout(Layout1.Clone(LayoutWorld));
	P:=P+Layout1.Width+MaxAbstand;
	C.Position.X:=P;
	LayoutWorld.AddObject(c);
end;
TRectangle(C.Children[0]).Fill.Color:=TAlphaColors.Orange;
TRectangle(C.Children[1]).Fill.Color:=TAlphaColors.Orange;


StartButton1.Visible:=False;
Reset;
end;

procedure TForm1.GameOver;
begin
LayoutWorld.HitTest:=False;
StartButton1.Text:='Game Over'  +LineFeed+
		'Punkte: '+IntToStr(StartButton1.Tag)+LineFeed+
		'Best: '+IntToStr(LayoutWorld.Tag);
StartButton1.Visible:=True;
StartButton1.BringToFront;

if LayoutWorld.Tag <StartButton1.Tag
then  LayoutWorld.Tag:=StartButton1.Tag;

end;

procedure TForm1.LayoutBirdPainting(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
Canvas.ClearRect(ARect,TAlphaColors.Yellow);
end;

procedure TForm1.LayoutWorldMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
if Not FloatAnimation1.Running then FloatAnimation1.Start;
FloatAnimation2.StopAtCurrent;
LayoutBird.RotationAngle:=-10;
FloatAnimation3.StopValue:=LayoutBird.Position.Y -LayoutBird.Height*3 ;
if FloatAnimation3.StopValue<LayoutBird.Height then FloatAnimation3.StopValue:=LayoutBird.Height;
FloatAnimation3.Start;
end;

procedure TForm1.Reset;
var
C:TLayout;
P:Single;
T:TPointF;
I:Integer;
begin
RandSeed:=342;
TagFloat:=Random;
P:=LayoutWorld.Width;
Layout1.Position.X:=P;



for I:=0 to LayoutWorld.ChildrenCount-1
do begin
	if Not(LayoutWorld.Children[I] is TLayout) then Continue;
	C:=TLayout(LayoutWorld.Children[I]);
	if C=LayoutBird then Continue;
	WayMaker(C);
	if C=Layout1 then Continue;
	P:=P+Layout1.Width+MaxAbstand;
	C.Position.X:=P
end;

With LayoutWorld Do T:=PointF(Width,Height);
With LayoutBird Do Position.Point:=(T-PointF(Width,Height))*0.5;

LayoutBird.RotationAngle:=0;
Pie1.EndAngle:=-90;
LayoutBird.BringToFront;


LayoutWorld.HitTest:=True;

StartButton1.Tag:=0;

MaxPointLabel.Text:=IntToStr(LayoutWorld.Tag);
PointLabel.Text:=IntToStr(StartButton1.Tag);

end;

procedure TForm1.StartButton1Click(Sender: TObject);
begin
StartButton1.Visible:=False;
Reset;
end;

procedure TForm1.WayMaker(const aMaster: TLayout);
var
H,M:TPointF;
R,E:Single;
begin
H.X:=LayoutWorld.Height;
H.Y:=2;
M.X:=LayoutBird.Height *6;


E:=M.X/H.X;
Repeat
R:=Random;
Until ((TagFloat+E)>R) And ((TagFloat -E)<R);
TagFloat:=R;
M.Y:=R*(H.X-M.X-2*H.Y);
With TRectangle(aMaster.Children[0]) Do Height:=H.Y+M.Y;
With TRectangle(aMaster.Children[1]) Do Height:=H.X-H.Y-M.Y-M.X   ;
aMaster.Tag:=0;

end;

end.
