#!/bin/bash

# Created by: Royce || schism || \x1p+2^] || wraithban
# Date Created: 17 September 2015

# creating boxes based off of string length?
# https://en.wikipedia.org/wiki/Box-drawing_character


box_draw()
{
 unset stringArray
 stringArray=[]

 TL="╔"		# Top-left piece
 TR="╗"		# Top-right piece
 BL="╚"		# Bottom-left piece
 BR="╝"		# Bottom-right piece
 HB="═"		# Horizontal Bar
 VB="║"		# Vertical Bar
 HSL="╠"	# Horizontal Split-left
 HSR="╣"	# Horizontal Split-right
 VST="╦"	# Vertical Split-top
 VSB="╩"	# Vertical Split-bottom
 i_hold=0

 string="${1}"					# Assigns input to be "string"
 string_lines=`echo -e ${string} | wc -l`	# Get the amount of lines
 stringLength=-1				# Set negative to offset the +1
 stringLong=0					# Longest line is '0' for now...
 while read line; do
  stringLength=$((stringLength+1))		# Negative 1 is now 0 (proper array start)
  stringArray[${stringLength}]="${line}"	# takes the parsed line and sets it in array.
  if [[ ${#stringArray[${stringLength}]} -gt ${stringLong} ]]; then
    stringLong=${#stringArray[${stringLength}]}	# If it is the longest line yet seen... applies it.
  fi
 done < <(echo -e "${string}")	# Sends the string passed to be parsed by the while
 				#  while statement

 height=$((string_lines+2))	# Height based off amount of lines.
 length=$((${stringLong}+4))	# length of the longest line (parsed by \n)
 cnt=0				# Standard variable use to iterate array.
 tComplete=0			# Variable used to identify no more text.
 i=0				# Standard variable use to iterate while statements.
 ih=0

# #  D E B U G  # #
# echo -e "Height: ${height}\nLength: ${length}\nCnt: ${cnt} "

# Top line of the box
 while [[ ${i} -lt ${length} ]]; do
  if [[ ${i} -eq ${i_hold} ]]; then
   printf ${TL}					# Top-left piece
  elif [[ $((i+1)) -eq ${length} ]]; then
   printf "${TR}\n"				# Top-right piece + new line
  else
   printf ${HB}					# Horizontal bar.
  fi
  i=$((i+1))
 done

 # Center of the box + text
 while [[ ${ih} -lt ${height} ]]; do
  i=0
  
  while [[ ${i} -lt ${length} ]]; do
   if [[ ${i} -eq ${i_hold} ]]; then
     printf ${VB}				# Vertical bar.
   elif [[ $((i+1)) -eq ${length} ]]; then
     printf "${VB}\n"				# Vertical bar + new line.
   elif [[ ${i} -eq $((i_hold+1)) && ${tComplete} -eq 0 && ${ih} -gt 0 ]]; then
     printf " %s" ${stringArray[${cnt}]}	# Prints the array
     i=$((${#stringArray[${cnt}]}+1))		# Sets up for the next iteration...
     cnt=$((cnt+1))				# Iterate thru the array.
     if [[ ${stringArray[${cnt}]} == "" &&  ${stringArray[${cnt}+1]} == "" ]]; then
      tComplete=1 				# Tells the application there's no more text.
     fi
   else
     printf " "
   fi
   i=$((i+1))
  done

  ih=$((ih+1))
 done


# Bottom line of the text box.
 i=0
 while [[ ${i} -lt ${length} ]]; do
  if [[ ${i} -eq ${i_hold} ]]; then
   printf ${BL}					# Bottom-left piece
  elif [[ $((i+1)) -eq ${length} ]]; then
   printf "${BR}\n"				# Bottom-right piece + new line
  else
  printf ${HB}					# Horizontal bar
  fi
  i=$((i+1))
 done
}

