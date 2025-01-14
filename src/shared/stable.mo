import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Result "mo:base/Result";

module {
    public type StabilityResult<T> = Result.Result<T, Text>;
    
    public type StableConfig = {
        batchSize: Nat;  // For batch processing
        retries: Nat;    // Number of retries for operations
        timeoutNs: Int;  // Timeout in nanoseconds
    };

    public class StableMemory<T>(config: StableConfig) {
        private var data = Buffer.Buffer<T>(0);
        private var lastBackupTime = Time.now();
        private let backupInterval = 24 * 60 * 60 * 1000_000_000; // 24 hours in nanoseconds

        // Basic Operations
        public func add(item: T) : StabilityResult<()> {
            try {
                data.add(item);
                _checkBackup();
                #ok(())
            } catch (e) {
                #err("Failed to add item: " # Error.message(e))
            }
        };

        public func get(index: Nat) : StabilityResult<T> {
            try {
                #ok(data.get(index))
            } catch (e) {
                #err("Failed to get item: " # Error.message(e))
            }
        };

        public func update(index: Nat, item: T) : StabilityResult<()> {
            try {
                data.put(index, item);
                _checkBackup();
                #ok(())
            } catch (e) {
                #err("Failed to update item: " # Error.message(e))
            }
        };

        public func remove(index: Nat) : StabilityResult<T> {
            try {
                let item = data.remove(index);
                _checkBackup();
                #ok(item)
            } catch (e) {
                #err("Failed to remove item: " # Error.message(e))
            }
        };

        // Batch Operations
        public func addBatch(items: [T]) : StabilityResult<()> {
            try {
                var processed = 0;
                let batches = _createBatches(items);
                
                for (batch in batches.vals()) {
                    for (item in batch.vals()) {
                        data.add(item);
                        processed += 1;
                    };
                    _checkBackup();
                };
                
                #ok(())
            } catch (e) {
                #err("Failed to add batch at item " # Nat.toText(processed))
            }
        };

        public func updateBatch(updates: [(Nat, T)]) : StabilityResult<()> {
            try {
                var processed = 0;
                let batches = _createBatches(updates);
                
                for (batch in batches.vals()) {
                    for ((index, item) in batch.vals()) {
                        data.put(index, item);
                        processed += 1;
                    };
                    _checkBackup();
                };
                
                #ok(())
            } catch (e) {
                #err("Failed to update batch at item " # Nat.toText(processed))
            }
        };

        // Backup and Restore
        public func backup() : StabilityResult<[T]> {
            try {
                lastBackupTime := Time.now();
                #ok(Buffer.toArray(data))
            } catch (e) {
                #err("Failed to create backup: " # Error.message(e))
            }
        };

        public func restore(backup: [T]) : StabilityResult<()> {
            try {
                data := Buffer.fromArray<T>(backup);
                lastBackupTime := Time.now();
                #ok(())
            } catch (e) {
                #err("Failed to restore from backup: " # Error.message(e))
            }
        };

        // Utility Functions
        public func toArray() : [T] {
            Buffer.toArray(data)
        };

        public func fromArray(array: [T]) {
            data := Buffer.fromArray<T>(array);
        };

        public func size() : Nat {
            data.size()
        };

        public func clear() {
            data.clear();
            lastBackupTime := Time.now();
        };

        // Private Helper Functions
        private func _checkBackup() {
            if (Time.now() - lastBackupTime > backupInterval) {
                ignore backup();
            };
        };

        private func _createBatches<B>(items: [B]) : [[B]] {
            let totalItems = items.size();
            let batchCount = (totalItems + config.batchSize - 1) / config.batchSize;
            
            Array.tabulate<[B]>(
                batchCount,
                func(i: Nat) : [B] {
                    let start = i * config.batchSize;
                    let end = Nat.min(start + config.batchSize, totalItems);
                    Array.tabulate<B>(
                        end - start,
                        func(j: Nat) : B { items[start + j] }
                    )
                }
            )
        };
    };
};