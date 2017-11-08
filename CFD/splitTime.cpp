#include<cmath>
#include"external.h"
#include<iostream>

#define days_in_seconds 60*60*24
#define hours_in_seconds 3600

void splitTime(const int time_elapsed,double* timeArray){

    
    double time = time_elapsed;
    std::cout << "Time elapsed = " << time << '\n';
    double days,hours,minutes,seconds = 0;

    double difference,remainder = 0;
    
    if(time >= days_in_seconds){
      difference = time/days_in_seconds;
      days = floor(difference);
      remainder =  difference - days;
    }
    else{
      days = 0;
    }
    
    if(time >= hours_in_seconds){
      if (remainder != 0){
	difference = remainder * days_in_seconds / hours_in_seconds;
      }
      else{
	difference = time/hours_in_seconds;
      }
      hours = floor(difference);
      remainder = difference - hours;
    }
    else{
      hours = 0;
      remainder = 0;
    }

    if(time >= 60){
      if(remainder !=0){
	difference = remainder / 60 * hours_in_seconds;
      }
      else{
	difference = time/60;
      }
      minutes = floor(difference);
      remainder = difference - minutes;
      seconds = floor(remainder * 60);
    }
    else{
      minutes = 0;
      seconds = time;
    }
    
    timeArray[0] = days;
    timeArray[1] = hours;
    timeArray[2] = minutes;
    timeArray[3] = seconds;

}
