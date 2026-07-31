# 视频转文字回放工具（Video to Text Tool）

把直播回放、会议录音、课程视频等**音视频文件**一键转换成**带时间戳的文字稿（SRT）**。

基于开源语音识别大模型 [Whisper](https://github.com/openai/whisper)（GGML 推理框架），完全在本机离线运行，不上传任何数据。

## 功能

- 支持任意常见音视频格式（mp4 / mkv / mov / wav / mp3 ...）
- 输出 `transcript.srt`（带时间戳字幕）+ `transcript.json`
- 三档识别精度可选，按需权衡速度与准确度
- 纯本地运行，无需联网（模型下载一次后即可离线使用）

## 三档模型

| 档位 | 模型 | 速度 | 准确度 | 适合场景 |
|------|------|------|--------|----------|
| 1 快速 | tiny (q8_0) | 最快 | 较低 | 粗看内容、时效性优先 |
| 2 标准 | small (q8_0) | 中等 | 良好 | 日常转换（默认） |
| 3 精确 | large-v3 | 最慢 | 最高 | 正式稿、需高准确度 |

## 使用方法

1. **下载模型和依赖**（仅首次，约 3.4 GB）：双击运行 `get_models.bat`，它会自动下载三个识别模型，并下载解压 FFmpeg（生成 `1.exe`）。等待全部完成。
2. **转换视频**：把视频文件直接拖到 `4.bat` 上，松手。
3. 黑窗口会让你选档位（直接回车 = 标准档），选好后等待。
4. 结束后同文件夹内生成 `transcript.srt`，用记事本打开即为带时间戳的文字稿。

> 提示：识别阶段需要几分钟，请耐心等待窗口跑完，不要提前关闭。

## 文件清单

| 文件 | 说明 |
|------|------|
| `1.exe` | FFmpeg，负责抽取音轨（由 get_models.bat 自动下载） |
| `2.exe` | Whisper-CLI，语音识别引擎 |
| `4.bat` | 一键启动脚本（拖视频到它上面） |
| `get_models.bat` | 一键下载三个模型 + FFmpeg |
| `whisper.dll` / `ggml.dll` / `ggml-base.dll` / `ggml-cpu-haswell.dll` | 运行依赖库 |
| `m_fast.bin` / `m_mid.bin` / `m_large.bin` | 三个模型（由 get_models.bat 下载） |

## 说明

- 识别结果由机器学习模型生成，可能存在同音错别字或时间戳误差，正式用途请人工校对。
- 本工具仅做「机器初稿」，校对环节建议人工完成。
- 核心识别能力来自 [whisper.cpp](https://github.com/ggml-org/whisper.cpp)，本仓库为其 Windows 一键封装。

## 开源协议

[MIT License](LICENSE)
