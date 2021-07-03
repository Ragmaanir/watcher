require "./spec_helper"

TEST_FILE = "src/watcher.cr"
TIMESTAMP = Watcher.timestamp_for(TEST_FILE)

describe Watcher do
  it "verify Watcher::WatchEvent.event.files" do
    Watcher.watch(TEST_FILE) do |changes, state|
      state.timestamps.should eq({TEST_FILE => TIMESTAMP})
      changes.should eq({TEST_FILE => Watcher::Status::CREATED})
      break
    end
  end

  it "more than one watcher" do
    spawn do
      Watcher.watch(TEST_FILE) do
        sleep 1
        File.delete("spec/foo").should eq(nil)
        break
      end
    end
    Watcher.watch(TEST_FILE) do
      File.write("spec/foo", "")
      sleep 2
      break
    end
  end
end
