var gulp = require('gulp'),
    zip = require('gulp-zip'),
    tar = require('gulp-tar'),
    gzip = require('gulp-gzip'),
    del = require('del'),
    package = require('./package.json');

var version = package.version;

gulp.task('stage', ['clean'], function(cb) {
	return gulp.src(['**/*', '!node_modules/**', '!node_modules'])
		.pipe(gulp.dest('stage/elasticsearch-demo-' + version));
});

gulp.task('zip', [], function() {
    return gulp.src(['stage/**/*'])
		.pipe(zip('elasticsearch-demo-' + version + '.zip'))
		.pipe(gulp.dest('dist'));
});

gulp.task('tar', [], function() {
    return gulp.src(['stage/**/*'])
		.pipe(tar('elasticsearch-demo-' + version + '.tar'))
		.pipe(gzip())
		.pipe(gulp.dest('dist'));
});

gulp.task('clean', function(cb) {
    del(['dist', 'stage'], cb)
});

gulp.task('default', ['clean', 'stage'], function() {
	gulp.start('zip', 'tar');
});
