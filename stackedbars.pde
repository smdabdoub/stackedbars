

int graphWidth = 1280; 
int graphHeight = 480;
int[] barStart = {10, 10};
int barWidth = 2;
int winWidth = barStart[0]*2+graphWidth;
int winHeight = barStart[1]*2+graphHeight;
int species = 10;
int[][] colors = {{178,16,67},{26,212,22},{252,46,193},{27,80,185},{153,204,238},
                  {214,113,11},{246,252,37},{193,93,96},{147,197,163},{132,41,227}};
float[][] randLengths;
boolean filled = false;
boolean sideways = false;

int zoomWidth = 35;
int zoomBoxStrokeWeight = 2;
boolean holdZoom = false;
int holdX = 0;
int NO_BAR_SELECTION = -1;

void setup() {
  //size(winWidth, winHeight);
  size(1300,500);
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
  int lenDex = 0;
  for(int i=barStart[0]; i <= graphWidth+barStart[0]; i+=barWidth) {
    drawColumn(i, randLengths[lenDex], barStart[1], graphHeight);
    lenDex++;
  }
  
  int barIndex = drawBarZoom();
  if (barIndex != NO_BAR_SELECTION && holdZoom)
    drawZoomInfo(barIndex);
}

int drawBarZoom() {
  if (holdZoom && holdX <= 0) return NO_BAR_SELECTION;

  //draw zoom if mouse over graph
  if (holdZoom || mouseX >= barStart[0] && mouseX <= barStart[0]+graphWidth && mouseY >= barStart[1] && mouseY <= barStart[1]+graphHeight) {
    int mx = holdZoom ? holdX : mouseX;
    holdX = mx;    
    int barIndex = (mx-barStart[0]) / barWidth;
    // draw zoomed bar
    strokeWeight(zoomWidth);
    strokeCap(SQUARE);
    drawColumn(mx, randLengths[barIndex], zoomBoxStrokeWeight, winHeight-zoomBoxStrokeWeight*2);
    //draw zoom boundary
    noFill();
    stroke(0);
    strokeWeight(zoomBoxStrokeWeight);
    rect(mx - zoomWidth/2, 1, zoomWidth, winHeight-2);
    
    return barIndex;
  }
  
  return NO_BAR_SELECTION;
}

void drawZoomInfo(int barIndex) {
  float[] bar = randLengths[barIndex];
  float barCursorPct = mouseY/float(winHeight);
  float laggingSum = 0;
  for (int i = 0; i < bar.length; i++) {
    if (barCursorPct >= laggingSum && barCursorPct < (laggingSum + bar[i])) {
      drawBarSectionInfo(barIndex, i);
      break;
    }
    laggingSum += bar[i];
  }
  //TODO: draw whole-column info
}

void drawBarSectionInfo(int barIndex, int secIdx) {
  int ibWidth = 200, ibHeight = 100, ibXOffset = 10, ibYOffset=10;
  int xStart = holdX+round(zoomWidth/2.0);
  int yStart = mouseY-round(ibHeight/2.0);
  // shadow
  fill(125);
  stroke(0);
  strokeWeight(0.3);
  rect(xStart+ibXOffset+3.5, yStart+3.5, ibWidth, ibHeight, 12.5);
  // draw info box
  fill(255);
  stroke(0);
  strokeWeight(2);
  rect(xStart+ibXOffset, yStart, ibWidth, ibHeight, 10);
  // draw triangle pointer
  line(xStart, yStart+round(ibHeight/2.0), xStart+ibXOffset, yStart+round(ibHeight/2.0)-ibYOffset);
  line(xStart, yStart+round(ibHeight/2.0), xStart+ibXOffset, yStart+round(ibHeight/2.0)+ibYOffset);
  //fill area within pointer
  strokeWeight(1);
  stroke(255);
  triangle(xStart+2, yStart+round(ibHeight/2.0), xStart+ibXOffset+2, yStart+round(ibHeight/2.0)-ibYOffset+1, xStart+ibXOffset+2, yStart+round(ibHeight/2.0)+ibYOffset-1);
  // fill info box with info
  strokeWeight(1);
  int[] ibOrigin = new int[]{round(xStart+ibXOffset*1.5), round(yStart+ibYOffset*1.5)};
  stroke(50);
  fill(colors[secIdx][0], colors[secIdx][1], colors[secIdx][2]);
  rect(ibOrigin[0], ibOrigin[1], 10, 10);
}

void drawColumn(int col, float[] bar, float yStart, int barHeight) {
  float laggingSum = yStart;
  
  for (int i=0; i < species; i++) {
    stroke(colors[i][0], colors[i][1], colors[i][2]);
    line(col, laggingSum, col, (laggingSum+bar[i]*barHeight));
    laggingSum += bar[i]*barHeight;
  }
}


float[][] fillRandomArray(int rows, int cols, int barHeight) {
  float[][] ra = new float[rows][cols];
  
   for (int i=0; i < rows; i++) {
       ra[i] = randomLengths(barHeight, species);
   } 
   return ra;
}


float[] randomLengths(int barHeight, int bins) {
  int prob = 1;
  float[] lens = new float[bins];
  int[] sign = {1, -1};
  float sum = 0;
  
  for (int i = 0; i < bins-1; i++) {
    lens[i] = random(prob*0.08, prob*0.1);
    lens[i] += sign[i%2] * random(prob*0.05);
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
