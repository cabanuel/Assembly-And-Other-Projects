//main.c
int l_strlen(const char *);
int l_strcmp(const char *str1, const char *str2);
int l_gets(int fd, char *buf, int len);
void l_puts(const char *buf);
int l_write(int fd, const char *buf, int len);
int l_open(const char *name, int flags, int mode);
int l_close(int fd);
int l_exit(int rc);
#define O_RDONLY 0
#define O_WRONLY 1
#define O_RDWR   2
char prompt[] = "Enter a string: ";
char msg1[] = "Echoing file: ";
char msg2[] = "Failed to open input file\n";
char equal[] = "The strings are the same\n";
char diff[] = "The strings are different\n";
int main(int argc, char **argv, char **envp) {
   int i;
   char newline = '\n';
   int len1, len2;
   char str1[512];
   char str2[512];
   int fd;
   for (i = 0; i < argc; i++) {
      l_puts(argv[i]);
      l_write(1, &newline, 1);
   }
   l_write(1, &newline, 1);
   if (argc > 1) {
      for (i = 1; i < argc; i++) {
      l_puts(msg1);
      l_puts(argv[i]);
      l_write(1, &newline, 1);
      fd = l_open(argv[i], O_RDONLY, 0);
      if (fd == -1) {
         l_puts(msg2);
      }
      else 
      {
         int len;
         while ((len = l_gets(fd, str1, 79)) > 0) {
            l_write(1, str1, len);
            }     
         l_close(fd);
      }
   }
      }
   l_write(1, &newline, 1);
   while (1) {
      l_write(1, prompt, l_strlen(prompt));
      len1 = l_gets(0, str1, 512);
      str1[len1] = 0;
      if (l_strcmp(str1, "quit\n") == 0) {
         break;
}
      l_puts(prompt);
      len2 = l_gets(0, str2, 512);
      str2[len2] = 0;
      if (l_strcmp(str1, str2) == 0) {
         l_puts(equal);
} else {
         l_puts(diff);
      }
   }
   l_exit(7);
   return 0;
}






























// //main.c

// #include <stdio.h>

// int l_strlen(const char *);
// int l_strcmp(const char *str1, const char *str2);
// int l_gets(int fd, char *buf, int len);
// int l_write(int fd, const char *buf, int len);
// int l_open(const char *name, int flags, int mode);
// int l_close(int fd);
// int l_exit(int rc);

// #define O_RDONLY 0
// #define O_WRONLY 2

// #define O_RDWR   2

// char prompt[] = "Enter a string: ";
// char msg1[] = "Echoing file: ";
// char msg2[] = "Failed to open input file\n";
// //char equal[] = "same\n";
// char equal[] = "The strings are the same\n";
// char diff[] = "The strings are different\n";
// //char diff[] = "different\n";

// int main(int argc, char **argv) {
//    int i;
//    char newline = '\n';
//    int len1, len2;
//    char str1[80];
//    char str2[80];
//    int fd;

//    // l_write(1, "poo12345p", l_strlen("poop12345"));
//    //l_write(1, &newline, 1);
 
//    //printf("poop");
//    //i = l_strlen("poop");

//    //printf("TEST 1 : %d\n",i );


//    // for (i = 0; i < argc; i++) {
//    //    l_write(1, argv[i], l_strlen(argv[i]));
//    //    l_write(1, &newline, 1);
//    // }

//    // l_write(1, &newline, 1);

//   if (argc > 1) {
//       l_write(1, msg1, l_strlen(msg1));
//       l_write(1, argv[1], l_strlen(argv[1]));
//       l_write(1, &newline, 1);
//       fd = l_open(argv[1], O_RDONLY, 0);
//       if (fd == -1) {
//          l_write(1, msg2, l_strlen(msg2));
//       }
//       else {
//          int len;
//          while ((len = l_gets(fd, str1, 79)) > 0) {
//             l_write(1, str1, len);
//             }
//          l_close(fd);
//             }
// }

//    l_write(1, &newline, 1);

// while(1){
//       l_write(1, prompt, l_strlen(prompt));
//       len1 = l_gets(0, str1, 79);
//       str1[len1] = 0;
//       //l_write(1, &newline, 1);
//       //l_write(1, "print|", l_strlen("print|"));
//      // l_write(1,str1,l_strlen(str1));
//       //l_write(1, "|endprint", l_strlen("|endprint"));
//       //l_write(1, &newline, 1);
//       // l_write(1, &newline, 1);
//       if (l_strcmp(str1, "quit\n") == 0) {
//          break;
//          }
//       l_write(1, prompt, l_strlen(prompt));
//       len2 = l_gets(0, str2, 79);
//       str2[len2] = 0;
//       //l_write(1, &newline, 1);
//       //l_write(1,str2,l_strlen(str2));
//       l_write(1, &newline, 1);

//       if (l_strcmp(str1, str2) == 0) {
//          l_write(1, equal, l_strlen(equal));
//          } 
//       else {
//          l_write(1, diff, l_strlen(diff));
//          }
//    }

   
//    //l_exit(0);
//    return 0;
// }