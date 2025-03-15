breed [pessoas pessoa]
pessoas-own [probabilidade]
globals [bateria1 bateria2 numMovimentos numContentores residuosGreen residuosYellow residuosPink residuosTotal residuosCleaner1 residuosCleaner2 maxbateria maxdetritos tempCharging1 tempCharging2 charging1 charging2 full1 full2]

to setup
  clear-all
  set numMovimentos 0
  set tempCharging1 Tempo_Carregamento1
  set tempCharging2 Tempo_Carregamento2
  set bateria1 Bateria_Inicial1
  set bateria2 Bateria_Inicial2
  set charging1 false
  set charging2 false
  set full1 false
  set full2 false

  ; Contagem de resíduos
  set residuosGreen 0
  set residuosYellow 0
  set residuosPink 0
  set residuosTotal 0
  set residuosCleaner1 0
  set residuosCleaner2 0

  set maxbateria 100.00
  set maxdetritos Numero_Detritos
  set numContentores Numero_Depositos

  ask patches [ set pcolor blue ]

  ; Criar postos de carregamento
  create-turtles 1 [
    set shape "house"
    setxy 0 0
    set color white
    set size 1.0
  ]

  create-turtles 1 [
    set shape "house"
    setxy 0 25
    set color white
    set size 1.0
  ]

  create-turtles 1 [
    set shape "house"
    setxy 25 25
    set color white
    set size 1.0
  ]

  create-turtles 1 [
    set shape "house"
    setxy 25 0
    set color white
    set size 1.0
  ]

  ; Criar contentor
  create-turtles numContentores [
    set shape "box"
    setxy random-pxcor random-pycor
    set heading one-of [0 90 180 270]
    set color brown
    set size 1.0
  ]

  ; Criar polluters com diferentes taxas de probabilidade
  create-pessoas 1 [
    set shape "person"
    setxy random-pxcor random-pycor
    set heading one-of [0 90 180 270]
    set color (green + 2)
    set size 1.0
    set probabilidade Taxa_Probabilidade_Green
  ]

  create-pessoas 1 [
    set shape "person"
    setxy random-pxcor random-pycor
    set heading one-of [0 90 180 270]
    set color yellow
    set size 1.0
    set probabilidade Taxa_Probabilidade_Yellow
  ]

  create-pessoas 1 [
    set shape "person"
    setxy random-pxcor random-pycor
    set heading one-of [0 90 180 270]
    set color (pink + 2)
    set size 1.0
    set probabilidade Taxa_Probabilidade_Pink
  ]

  ; Criar cleaners
  create-turtles 1 [
    set shape "airplane"
    setxy 0 0
    set heading one-of [0 90 180 270]
    set color cyan
    set size 1.0
  ]

  create-turtles 1 [
    set shape "airplane"
    setxy 25 25
    set heading one-of [0 90 180 270]
    set color (violet + 2)
    set size 1.0
  ]

  reset-ticks
end

;----------------------------------------------------------------------------
to go_once

  ask pessoas [
    if [pcolor] of patch-here = blue [
      if random-float 1 < probabilidade [ set pcolor color ]
    ]
    movimentacao
  ]

  ; Movimentação avião 1
  handle_airplane cyan bateria1 residuosCleaner1 charging1 full1 tempCharging1
  ; Movimentação avião 2
  handle_airplane (violet + 2) bateria2 residuosCleaner2 charging2 full2 tempCharging2

  tick
end

;----------------------------------------------------------------------------
to go_n

  if ticks < N_Ticks [
    ask pessoas [
      if [pcolor] of patch-here = blue [
        if random-float 1 < probabilidade [ set pcolor color ]
      ]
      movimentacao
    ]

    ; Movimentação avião 1
    handle_airplane cyan bateria1 residuosCleaner1 charging1 full1 tempCharging1
    ; Movimentação avião 2
    handle_airplane (violet + 2) bateria2 residuosCleaner2 charging2 full2 tempCharging2
  ]

  if ticks >= N_Ticks [ stop ]
  tick
end

;----------------------------------------------------------------------------
to go

  ask pessoas [
    if [pcolor] of patch-here = blue [
      if random-float 1 < probabilidade [ set pcolor color ]
    ]
    movimentacao
  ]

  ; Movimentação avião 1
  handle_airplane cyan bateria1 residuosCleaner1 charging1 full1 tempCharging1
  ; Movimentação avião 2
  handle_airplane (violet + 2) bateria2 residuosCleaner2 charging2 full2 tempCharging2

  tick
end

;----------------------------------------------------------------------------
to handle_airplane [airplane_color bateria residuosCleaner charging full tempCharging]

  ask turtles with [shape = "airplane" and color = airplane_color ] [
    let contentor_maisprox min-one-of turtles with [shape = "box"] [ (abs (xcor - [xcor] of myself)) + (abs (ycor - [ycor] of myself)) ]
    let posto_maisprox min-one-of turtles with [shape = "house"] [ (abs (xcor - [xcor] of myself)) + (abs (ycor - [ycor] of myself)) ]
    let distanceContentor distance contentor_maisprox
    let distancePosto distance posto_maisprox

    if residuosCleaner < maxdetritos [
      if posto_maisprox != nobody [
        if bateria <= distancePosto and not charging [ gotoPosto airplane_color bateria charging tempCharging]
        if bateria > distancePosto and not charging [ movimentacao_airplane airplane_color bateria residuosCleaner charging]
      ]
    ]

    if residuosCleaner = maxdetritos [
      if contentor_maisprox != nobody and posto_maisprox != nobody [
        if airplane_color = cyan [ set full1 true ]
        if airplane_color = (violet + 2) [ set full2 true ]
        if bateria > (distancePosto + distanceContentor) and not charging [ gotoContentor airplane_color bateria residuosCleaner charging tempCharging full ]
        if bateria <= (distancePosto + distanceContentor) and not charging [ gotoPosto airplane_color bateria charging tempCharging]
      ]
    ]

    if xcor = [xcor] of posto_maisprox and ycor = [ycor] of posto_maisprox [
      if airplane_color = cyan [ set charging1 true ]
      if airplane_color = (violet + 2) [ set charging2 true ]
      if charging1 and airplane_color = cyan [ chargingBat cyan ]
      if charging2 and airplane_color = (violet + 2) [ chargingBat (violet + 2) ]
    ]
  ]
end

;----------------------------------------------------------------------------
to movimentacao

  if shape = "person" [
    let adjacente-azul one-of neighbors4 with [pcolor = blue]
    if adjacente-azul != nobody [
      face adjacente-azul
      move-to adjacente-azul
    ]
    if adjacente-azul = nobody [
      let direction one-of ["forward" "backward" "right" "left"]
      if direction = "forward" [forward 1]
      if direction = "backward" [back 1]
      if direction = "right" [right 90 forward 1]
      if direction = "left" [left 90 forward 1]
    ]
  ]
end

;----------------------------------------------------------------------------
to movimentacao_airplane [airplane_color bateria residuosCleaner charging]

  ask turtles with [shape = "airplane" and color = airplane_color] [
    if bateria > 0 and not charging [
      let adjacente one-of neighbors4 with [pcolor = (green + 2) or pcolor = yellow or pcolor = (pink + 2)]

      if adjacente != nobody [
        face adjacente
        move-to adjacente
        if airplane_color = cyan [ set bateria1 bateria1 - 1 ]
        if airplane_color = (violet + 2) [ set bateria2 bateria2 - 1 ]
        set numMovimentos numMovimentos + 1
        if residuosCleaner < maxdetritos [ contadorResiduos airplane_color]
      ]
      if adjacente = nobody [
        let direction one-of ["forward" "backward" "right" "left"]
        if direction = "forward" [forward 1]
        if direction = "backward" [back 1]
        if direction = "right" [right 90 forward 1]
        if direction = "left" [left 90 forward 1]
        if airplane_color = cyan [ set bateria1 bateria1 - 1 ]
        if airplane_color = (violet + 2) [ set bateria2 bateria2 - 1 ]
        set numMovimentos numMovimentos + 1
      ]
    ]
  ]
end

;----------------------------------------------------------------------------
to contadorResiduos [airplane_color]

  let current-patch patch-here
  if [pcolor] of current-patch != blue [

    if [pcolor] of current-patch = (green + 2) [ set residuosGreen residuosGreen + 1 ]
    if [pcolor] of current-patch = yellow [ set residuosYellow residuosYellow + 1 ]
    if [pcolor] of current-patch = (pink + 2) [ set residuosPink residuosPink + 1 ]

    set residuosTotal residuosGreen + residuosYellow + residuosPink
    if airplane_color = cyan [ set residuosCleaner1 residuosCleaner1 + 1 ]
    if airplane_color = (violet + 2) [ set residuosCleaner2 residuosCleaner2 + 1 ]

    set pcolor blue
  ]
end

;----------------------------------------------------------------------------
to gotoPosto [ airplane_color bateria charging tempCharging ]

  if shape = "airplane" and color = airplane_color [
    let posto_maisprox min-one-of turtles with [shape = "house"] [ (abs (xcor - [xcor] of myself)) + (abs (ycor - [ycor] of myself)) ]

    if bateria >= 0 [
      if xcor != [xcor] of posto_maisprox [
        if xcor > [xcor] of posto_maisprox [ set xcor xcor - 1 ]
        if xcor < [xcor] of posto_maisprox [ set xcor xcor + 1 ]
      ]
      if xcor = [xcor] of posto_maisprox and ycor != [ycor] of posto_maisprox [
        if ycor > [ycor] of posto_maisprox [ set ycor ycor - 1 ]
        if ycor < [ycor] of posto_maisprox [ set ycor ycor + 1 ]
      ]

      set bateria bateria - 1
      set numMovimentos numMovimentos + 1
    ]

    if xcor = [xcor] of posto_maisprox and ycor = [ycor] of posto_maisprox [
      if airplane_color = cyan [ set charging1 true ]
      if airplane_color = (violet + 2) [ set charging2 true ]
      if charging1 and airplane_color = cyan [ chargingBat cyan ]
      if charging2 and airplane_color = (violet + 2) [ chargingBat (violet + 2)]
    ]
  ]
end

;----------------------------------------------------------------------------
to gotoContentor [ airplane_color bateria residuosCleaner charging tempCharging full ]

  if shape = "airplane" and color = airplane_color [
    if residuosCleaner = maxdetritos [

      let contentor_maisprox min-one-of turtles with [shape = "box"] [ (abs (xcor - [xcor] of myself)) + (abs (ycor - [ycor] of myself)) ]
      let posto_maisprox min-one-of turtles with [shape = "house"] [ (abs (xcor - [xcor] of myself)) + (abs (ycor - [ycor] of myself)) ]
      let distanceContentor distance contentor_maisprox
      let distancePosto distance posto_maisprox

      if bateria > (distanceContentor + distancePosto) [
        if xcor != [xcor] of contentor_maisprox [
          if xcor > [xcor] of contentor_maisprox [ set xcor xcor - 1 ]
          if xcor < [xcor] of contentor_maisprox [ set xcor xcor + 1 ]
        ]
        if ycor != [ycor] of contentor_maisprox [
          if ycor > [ycor] of contentor_maisprox [ set ycor ycor - 1 ]
          if ycor < [ycor] of contentor_maisprox [ set ycor ycor + 1 ]
        ]

        if distanceContentor = 0 [ descarregar airplane_color residuosCleaner full ]

        set bateria bateria - 1
        set numMovimentos numMovimentos + 1
      ]
    ]
  ]
end

;----------------------------------------------------------------------------
to chargingBat [airplane_color]
  ask turtles with [shape = "airplane" and color = airplane_color] [
    if airplane_color = cyan [
      if bateria1 < maxbateria [
        set bateria1 bateria1 + (maxbateria / tempCharging1)
        if bateria1 >= maxbateria [
          set bateria1 maxbateria
          set charging1 false
        ]
      ]
    ]

    if airplane_color = (violet + 2) [
      if bateria2 < maxbateria [
        set bateria2 bateria2 + (maxbateria / tempCharging2)
        if bateria2 >= maxbateria [
          set bateria2 maxbateria
          set charging2 false
        ]
      ]
    ]
  ]
end

;----------------------------------------------------------------------------
to descarregar [ airplane_color residuosCleaner full ]
  ask turtles with [shape = "airplane" and color = airplane_color] [
    if airplane_color = cyan [
      if residuosCleaner1 = maxdetritos [
        set residuosCleaner1 0
        set full1 false
      ]
    ]
    if airplane_color = (violet + 2) [
      if residuosCleaner2 = maxdetritos [
        set residuosCleaner2 0
        set full2 false
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
19
592
402
-1
-1
14.4
1
10
1
1
1
0
0
0
1
0
25
0
25
0
0
1
ticks
30.0

BUTTON
605
19
673
52
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
683
19
751
52
Go_Once
go_once
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
59
196
92
Taxa_Probabilidade_Green
Taxa_Probabilidade_Green
0
1
0.32
0.01
1
NIL
HORIZONTAL

SLIDER
14
19
196
52
Taxa_Probabilidade_Yellow
Taxa_Probabilidade_Yellow
0
1
0.64
0.01
1
NIL
HORIZONTAL

SLIDER
15
99
196
132
Taxa_Probabilidade_Pink
Taxa_Probabilidade_Pink
0
1
1.0
0.01
1
NIL
HORIZONTAL

MONITOR
606
171
714
216
Bateria Cleaner 1
bateria1
2
1
11

SLIDER
16
223
131
256
Bateria_Inicial1
Bateria_Inicial1
0
100
52.0
1
1
NIL
HORIZONTAL

MONITOR
605
63
737
108
Movimentos Cleaners
numMovimentos
0
1
11

MONITOR
718
116
819
161
Residuos Green
residuosGreen
0
1
11

MONITOR
606
116
707
161
Residuos Yellow
residuosYellow
0
1
11

MONITOR
831
116
931
161
Residuos Pink
residuosPink
0
1
11

SLIDER
15
360
196
393
Numero_Detritos
Numero_Detritos
0
500
223.0
1
1
NIL
HORIZONTAL

MONITOR
748
63
860
108
Total de Residuos
residuosTotal
0
1
11

SLIDER
16
304
197
337
Numero_Depositos
Numero_Depositos
2
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
15
140
189
173
Tempo_Carregamento1
Tempo_Carregamento1
1
100
27.0
1
1
NIL
HORIZONTAL

MONITOR
872
63
991
108
Residuos Cleaner 1
residuosCleaner1
0
1
11

PLOT
606
251
806
401
Contaminação
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count patches with [pcolor = (green + 2) or pcolor = yellow or pcolor = (pink + 2)]"

PLOT
819
251
1019
401
Limpeza
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count patches with [pcolor = blue]"

BUTTON
762
19
830
53
Go_N
go_n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
841
20
908
53
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
14
413
195
446
N_Ticks
N_Ticks
1
100
20.0
1
1
NIL
HORIZONTAL

TEXTBOX
18
342
220
368
Máximo de Detritos a Transportar
10
0.0
1

TEXTBOX
16
396
166
414
Número de Ticks para Go_N
10
0.0
1

MONITOR
725
170
833
215
Bateria Cleaner 2
bateria2
2
1
11

SLIDER
16
264
132
297
Bateria_Inicial2
Bateria_Inicial2
0
100
100.0
1
1
NIL
HORIZONTAL

MONITOR
1004
63
1123
108
Residuos Cleaner 2
residuosCleaner2
0
1
11

SLIDER
16
181
190
214
Tempo_Carregamento2
Tempo_Carregamento2
0
100
13.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
