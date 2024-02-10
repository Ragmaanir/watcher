require "./spec_helper"

TEST_FILE = "src/watcher.cr"
TIMESTAMP = Watcher.timestamp_for(TEST_FILE)

describe Watcher do
  it "verify block arguments" do
    Watcher.watch(TEST_FILE, skip_initial: false) do |changes, state|
      state.timestamps.should eq({TEST_FILE => TIMESTAMP})
      changes.should eq({TEST_FILE => Watcher::Status::Created})
      break
    end
  end

  it "more than one watcher" do
    spawn do
      Watcher.watch(TEST_FILE, skip_initial: false) do
        sleep 1
        File.delete("spec/foo").should eq(nil)
        break
      end
    end
    Watcher.watch(TEST_FILE, skip_initial: false) do
      File.write("spec/foo", "")
      sleep 2
      break
    end
  end
end
