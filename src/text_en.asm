CreatedByText db 'HUMAN CODED ASSEMBLY BY',0x0
KKJText db 'KRZYSZTOF KRYSTIAN JANKOWSKI',0x0
PressEnterText db 'PRESS ENTER', 0x0
MainMenuCopyText db '(MIT) 2025 P1X',0x0
QuitText db 'Thanks for playing!',0x0D,0x0A,'Visit http://smol.p1x.in/assembly for more...', 0x0D, 0x0A, 0x0

Fontset1Text db ' !',34,'#$%&',39,'()*+,-./:;<=>?',0x0
Fontset2Text db '@ 0123456789',0x0
Fontset3Text db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',0x0


HelpFooter1Text db '> PRESS ENTER FOR NEXT PAGE',0x0
HelpFooter2Text db '< PRESS ESC TO BACK TO MAIN MENU',0x0

HelpPage0Text:
  db 'CORTEX LABS - QUICK HELP!',0x0
  db ' ',0x0
  db '-------------------------------------',0x0
  db 'FOR FULL MANUAL CHECK @ FLOPPY IN DOS',0x0
  db 'READ > MANUAL.TXT < FILE',0x0
  db '-------------------------------------',0x0
  db ' ',0x0
  db 'TABLE OF CONTENT',0x0
  db '- GAME IDEA',0x0
  db '- BASE EXPANSION & BUILDINGS',0x0
  db '- RAILS MANAGEMENT',0x0
  db '- RESOURCES & UPGRADES',0x0
  db '- PAGE 5',0x0
  db '- PAGE 6',0x0
  db '- PAGE 7',0x0
  db 0x00

HelpPage1Text:
  db 'GAME IDEA',0x0
  db ' ',0x0
  db 'CORTEX LABS IS A STRATEGY PUZZLE GAME.',0x00
  db 'YOUR MISSION IS TO EXTRACT, REFINE,',0x0
  db 'AND RETURN RESOURCES ON OTHER PLANET.',0x0
  db '-------------------------------------',0x0
  db 0x00

HelpPage2Text:
  db 'BASE EXPANSION & BUILDINGS',0x0
  db ' ',0x0
  db 'PAGE 2 OF 7',0x0
  db 0x00

HelpPage3Text:
  db 'RAILS MANAGEMENT',0x0
  db ' ',0x0
  db 'PAGE 3 OF 7',0x0
  db 0x00

HelpPage4Text:
  db 'RESOURCES & UPGRADES',0x0
  db ' ',0x0
  db 'PAGE 4 OF 7',0x0
  db 0x00

HelpPage5Text:
db 'PAGE 5',0x0
db ' ',0x0
db 'PAGE 5 OF 7',0x0
db 0x00
HelpPage6Text:
db 'PAGE 6',0x0
db ' ',0x0
db 'PAGE 6 OF 7',0x0
db 0x00
HelpPage7Text:
  db 'PAGE 7',0x0
  db ' ',0x0
  db 'PAGE 7 OF 7',0x0
  db 0x00

HelpArrayText:
  dw HelpPage0Text
  dw HelpPage1Text
  dw HelpPage2Text
  dw HelpPage3Text
  dw HelpPage4Text
  dw HelpPage5Text
  dw HelpPage6Text
  dw HelpPage7Text
