/* READ RATINGS DATASET*/
data ratings;
	infile '/home/u48446390/ahmed/ratings.dat' dlmstr='::' 
		encoding=wlatin1;
	input UserID MovieID Rating TimeStamp;
run;

*READ MOVIES DATASET;
data movies;
infile '/home/u48446390/ahmed/movies.dat' dlmstr='::' encoding=wlatin1;
length name $ 90 Genre $ 50;
input MovieId Name $ Genre $;
run;

*MANIPULATING MOVIES DATASET AND SPLITTING GENRE;
data movies2;
set work.movies;
array g $15 g1-g5 ;
do i=1 to dim(g);
g{i} = scan(Genre, i, '|'); /* Splitting Genre*/
if g{1} in ('Action', 'Adventure', 'Animation', "Children's", 'Comedy', 'Crime', 'Documentary', 'Drama', 'Fantasy', 'Film-Noir', 'Horror',
			'Musical', 'Mystery', 'Romance', 'Sci-Fi', 'Thriller', 'War', 'Western') 
				then do; 
					g{i} = g{i}; 
					end;
end; /* seperate genres individually*/
Year = scan (name, -1);/*extract the years of the movies*/
Year = compress(Year, '()');
X=_n_;
drop i x ;
run;

*READ USERS; 

data users; DATASET
	infile '/home/u48446390/ahmed/users.dat' dlm='::';
	length ZipCode $ 10;
	input UserID Gender $ Age Occupation ZipCode $;
run;



/* Sort Rating dataset*/

proc sort data=work.ratings;
by UserID;
run;
/* Sort users dataset/*/

proc sort data=work.users;
by UserID;
run;

/* combine ratings and users datasets*/
data userratings;
merge work.ratings work.users;
by UserID;
run;

* sorting userRatings dataset to allow us to combine it with Movies;
proc sort data=work.userratings;
by MovieId;
run;

/* combine the sorted usersRatings with movies*/
data usermovieratings;
merge work.userratings work.movies2;
by MovieID;
drop TimeStamp ZipCode Gender Occupation Genre name Year; /*drop those which u fely is not in use*/
run;



*****************************************************************************************************;
*Running ANOVA test for UsersRating dataset;

Title "ANOVA test for Ratings and Age Groups";
ods noproctitle;
ods graphics / imagemap=on;

proc glm data=WORK.USERRATINGS plots(only)=(boxplot 
		diagnostics);
	class Age;
	model Rating=Age;
	means Age / hovtest=levene welch plots=none;
	lsmeans Age / adjust=tukey pdiff alpha=.05 plots=(meanplot diffplot);
	run;
quit;


*Finding the Frequency of users and movie ratings using PROC FREQ;
proc freq data=userratings;
	tables age * rating;
run;

*Generating Correlation test for userRatings;

PROC CORR DATA=work.userratings;
    VAR Age;
    WITH Rating;
RUN;



*********************************************************************;










