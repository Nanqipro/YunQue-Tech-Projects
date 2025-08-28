package logger

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/sirupsen/logrus"
	"gopkg.in/natefinch/lumberjack.v2"
)

var Logger *logrus.Logger

// LogConfig 日志配置
type LogConfig struct {
	Level      string `json:"level"`      // 日志级别
	Format     string `json:"format"`     // 日志格式 json/text
	Output     string `json:"output"`     // 输出方式 console/file/both
	FilePath   string `json:"file_path"`  // 日志文件路径
	MaxSize    int    `json:"max_size"`   // 单个日志文件最大大小(MB)
	MaxBackups int    `json:"max_backups"` // 保留的旧日志文件数量
	MaxAge     int    `json:"max_age"`    // 日志文件保留天数
	Compress   bool   `json:"compress"`   // 是否压缩旧日志文件
}

// InitLogger 初始化日志系统
func InitLogger(config LogConfig) {
	Logger = logrus.New()

	// 设置日志级别
	setLogLevel(config.Level)

	// 设置日志格式
	setLogFormat(config.Format)

	// 设置日志输出
	setLogOutput(config)

	// 添加钩子
	addHooks()

	Logger.Info("Logger initialized successfully")
}

// setLogLevel 设置日志级别
func setLogLevel(level string) {
	switch level {
	case "debug":
		Logger.SetLevel(logrus.DebugLevel)
	case "info":
		Logger.SetLevel(logrus.InfoLevel)
	case "warn":
		Logger.SetLevel(logrus.WarnLevel)
	case "error":
		Logger.SetLevel(logrus.ErrorLevel)
	case "fatal":
		Logger.SetLevel(logrus.FatalLevel)
	case "panic":
		Logger.SetLevel(logrus.PanicLevel)
	default:
		Logger.SetLevel(logrus.InfoLevel)
	}
}

// setLogFormat 设置日志格式
func setLogFormat(format string) {
	switch format {
	case "json":
		Logger.SetFormatter(&logrus.JSONFormatter{
			TimestampFormat: time.RFC3339,
		})
	case "text":
		Logger.SetFormatter(&logrus.TextFormatter{
			FullTimestamp:   true,
			TimestampFormat: "2006-01-02 15:04:05",
		})
	default:
		Logger.SetFormatter(&logrus.JSONFormatter{
			TimestampFormat: time.RFC3339,
		})
	}
}

// setLogOutput 设置日志输出
func setLogOutput(config LogConfig) {
	switch config.Output {
	case "console":
		Logger.SetOutput(os.Stdout)
	case "file":
		setFileOutput(config)
	case "both":
		setBothOutput(config)
	default:
		Logger.SetOutput(os.Stdout)
	}
}

// setFileOutput 设置文件输出
func setFileOutput(config LogConfig) {
	// 确保日志目录存在
	logDir := filepath.Dir(config.FilePath)
	if err := os.MkdirAll(logDir, 0755); err != nil {
		fmt.Printf("Failed to create log directory: %v\n", err)
		return
	}

	// 配置日志轮转
	lumberjackLogger := &lumberjack.Logger{
		Filename:   config.FilePath,
		MaxSize:    config.MaxSize,
		MaxBackups: config.MaxBackups,
		MaxAge:     config.MaxAge,
		Compress:   config.Compress,
	}

	Logger.SetOutput(lumberjackLogger)
}

// setBothOutput 设置同时输出到控制台和文件
func setBothOutput(config LogConfig) {
	// 确保日志目录存在
	logDir := filepath.Dir(config.FilePath)
	if err := os.MkdirAll(logDir, 0755); err != nil {
		fmt.Printf("Failed to create log directory: %v\n", err)
		Logger.SetOutput(os.Stdout)
		return
	}

	// 配置日志轮转
	lumberjackLogger := &lumberjack.Logger{
		Filename:   config.FilePath,
		MaxSize:    config.MaxSize,
		MaxBackups: config.MaxBackups,
		MaxAge:     config.MaxAge,
		Compress:   config.Compress,
	}

	// 使用MultiWriter同时输出到控制台和文件
	multiWriter := logrus.StandardLogger().WriterLevel(logrus.InfoLevel)
	Logger.SetOutput(multiWriter)
	Logger.AddHook(&FileHook{Writer: lumberjackLogger})
}

// addHooks 添加日志钩子
func addHooks() {
	// 添加调用者信息钩子
	Logger.AddHook(&CallerHook{})
}

// FileHook 文件输出钩子
type FileHook struct {
	Writer *lumberjack.Logger
}

func (hook *FileHook) Fire(entry *logrus.Entry) error {
	line, err := entry.String()
	if err != nil {
		return err
	}
	_, err = hook.Writer.Write([]byte(line))
	return err
}

func (hook *FileHook) Levels() []logrus.Level {
	return logrus.AllLevels
}

// CallerHook 调用者信息钩子
type CallerHook struct{}

func (hook *CallerHook) Fire(entry *logrus.Entry) error {
	if entry.HasCaller() {
		entry.Data["file"] = fmt.Sprintf("%s:%d", filepath.Base(entry.Caller.File), entry.Caller.Line)
		entry.Data["function"] = entry.Caller.Function
	}
	return nil
}

func (hook *CallerHook) Levels() []logrus.Level {
	return logrus.AllLevels
}

// 便捷方法
func Debug(args ...interface{}) {
	Logger.Debug(args...)
}

func Debugf(format string, args ...interface{}) {
	Logger.Debugf(format, args...)
}

func Info(args ...interface{}) {
	Logger.Info(args...)
}

func Infof(format string, args ...interface{}) {
	Logger.Infof(format, args...)
}

func Warn(args ...interface{}) {
	Logger.Warn(args...)
}

func Warnf(format string, args ...interface{}) {
	Logger.Warnf(format, args...)
}

func Error(args ...interface{}) {
	Logger.Error(args...)
}

func Errorf(format string, args ...interface{}) {
	Logger.Errorf(format, args...)
}

func Fatal(args ...interface{}) {
	Logger.Fatal(args...)
}

func Fatalf(format string, args ...interface{}) {
	Logger.Fatalf(format, args...)
}

func Panic(args ...interface{}) {
	Logger.Panic(args...)
}

func Panicf(format string, args ...interface{}) {
	Logger.Panicf(format, args...)
}

// WithFields 创建带字段的日志条目
func WithFields(fields logrus.Fields) *logrus.Entry {
	return Logger.WithFields(fields)
}

// WithField 创建带单个字段的日志条目
func WithField(key string, value interface{}) *logrus.Entry {
	return Logger.WithField(key, value)
}

// WithError 创建带错误信息的日志条目
func WithError(err error) *logrus.Entry {
	return Logger.WithError(err)
}