# Nginx Architecture

#nginx

> event driven architecture:- 


## Event Handling

1. nginx logs the requests and loops, checking for new events without blocking
2.  if waiting on data, nginx handles another event instead of pausing
3.  this architecture enables nginx to manage many connections at once.
![[Pasted image 20260330220224.png]]

## Worker Process

![[Pasted image 20260330220111.png]]