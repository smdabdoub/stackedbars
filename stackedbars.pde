

int graphWidth = 1280; 
int graphHeight = 480;
int[] barStart = {10, 10};
int barWidth = 2;
int winWidth = barStart[0]*2+graphWidth;
int winHeight = barStart[1]*2+graphHeight;
int species = 10;
int[][] colors = {{178,16,67},{26,212,22},{252,46,193},{27,80,185},{153,204,238},
                  {214,113,11},{246,252,37},{193,93,96},{147,197,163},{132,41,227}};
int[][] randLengths;
boolean filled = false;

int zoomWidth = 35;
boolean holdZoom = false;
int holdX = 0;
int NO_BAR_SELECTION = -1;

void setup() {
  size(winWidth, winHeight);
  smooth();
  randLengths = fillRandomArray(ceil((graphWidth+barStart[0])/barWidth), species, graphHeight);
}

void draw() {
  background(175);
  // draw boundary
  fill(175);
  stroke(255);
  rect(barStart[0],barStart[1],graphWidth,graphHeight);
  // draw graph
  strokeWeight(barWidth + 0.5);
  strokeCap(PROJECT);
  int lenDex = 0;
  for(int i=barStart[0]; i <= graphWidth+barStart[0]; i+=barWidth) {
    drawColumn(i, randLengths[lenDex]);
    lenDex++;
  }
  
  int barIndex = drawBarZoom();
  if (barIndex != NO_BAR_SELECTION && holdZoom)
    drawZoomInfo(barIndex);
}

int drawBarZoom() {
  if (holdZoom && holdX < 0) return NO_BAR_SELECTION;

  //draw zoom if mouse over graph
  if (holdZoom || mouseX >= barStart[0] && mouseX <= barStart[0]+graphWidth && mouseY >= barStart[1] && mouseY <= barStart[1]+graphHeight) {
    int mx = holdZoom ? holdX : mouseX;
    holdX = mx;
    int barIndex = (mx-barStart[0]) / barWidth;
    // draw zoomed bar
    strokeWeight(zoomWidth);
    strokeCap(PROJECT);
    drawColumn(mx, randLengths[barIndex]);  //TODO: still err if holdX was < barStart[0]
    //draw zoom boundary
    noFill();
    stroke(0);
    strokeWeight(2);
    rect(mx - zoomWidth/2, 1, zoomWidth, winHeight-2);
    
    return barIndex;
  }
  
  return NO_BAR_SELECTION;
}

void drawZoomInfo(int barIndex) {
  int[] bar = randLengths[barIndex];
  int barCursorPct = round(mouseY/float(winHeight) * 100);
  int i, laggingSum = 0;
  println(bar.length);
  for (i = 0; i < bar.length; i++) {
    if (barCursorPct >= laggingSum && barCursorPct < laggingSum + (bar[i]/float(graphHeight))*winHeight) {
      drawBarSectionInfo(bar, i);
      println(i);
    }
    laggingSum += bar[i];
  }
  // draw general bar info
  
}

void drawBarSectionInfo(int[] bar, int secIdx) {
  fill(255);
  stroke(0);
  strokeWeight(1);
  // draw info box
  int ibWidth = 200, ibHeight = 100, ibXOffset = 10, ibYOffset=10;
  int xStart = holdX+round(zoomWidth/2.0);
  int yStart = mouseY-round(ibHeight/2.0);
  rect(xStart+ibXOffset, yStart, ibWidth, ibHeight);
  // draw triangle pointer
  triangle(xStart, yStart+round(ibHeight/2.0), xStart+ibXOffset, yStart+round(ibHeight/2.0)-ibYOffset, xStart+ibXOffset, yStart+round(ibHeight/2.0)+ibYOffset);
  stroke(255);
  line(xStart+ibXOffset, yStart+round(ibHeight/2.0)-ibYOffset+1, xStart+ibXOffset, yStart+round(ibHeight/2.0)+ibYOffset-1);
  // fill info box with info
  //PVector ibOrigin
}

void drawColumn(int col, int[] bar) {
  int laggingSum = 0;
  
  for (int i=0; i < species; i++) {
    stroke(colors[i][0], colors[i][1], colors[i][2]);
    line(col, barStart[1]+laggingSum, col, barStart[1]+laggingSum+bar[i]);
    laggingSum += bar[i];
  }
}


int[][] fillRandomArray(int rows, int cols, int height) {
  int[][] ra = new int[rows][cols];
  
   for (int i=0; i < rows; i++) {
       ra[i] = randomLengths(graphHeight, species);
   } 
   return ra;
}


int[] randomLengths(int height, int bins) {
  int prob = height;
  int[] lens = new int[bins];
  int[] sign = {1, -1};
  int sum = 0;
  
  for (int i = 0; i < bins-1; i++) {
    lens[i] = int(random(prob*0.08, prob*0.1));
    lens[i] += sign[i%2] * int(random(prob*0.05));
    sum += lens[i];
  }
  lens[bins-1] = prob - sum;
  return lens;
}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      holdZoom = true;
      holdX = mouseX;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      holdZoom = false;
    }
  }
}
